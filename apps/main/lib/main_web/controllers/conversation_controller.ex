defmodule MainWeb.ConversationController do
  use MainWeb.SecuredContoller

  alias Data.{
    Campaign,
    CampaignRecipient,
    Conversations,
    ConversationMessages,
    Location,
    TeamMember,
    TimezoneOffset}
  alias MainWeb.Helper.Formatters
  alias MainWeb.AssignTeamMemberController

  require Logger

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  NimbleCSV.define(MyParser, [])

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    conversations =
      conn
      |> current_user()
      |> Conversations.all(location_id)

    my_conversations =
      Enum.filter(conversations, fn(c) -> c.team_member && c.team_member.user_id == current_user(conn).id end)

    dispositions =
      conn
      |> current_user()
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
      |> Stream.map(&({&1.disposition_name, &1.id}))
      |> Enum.to_list()

    render conn, "index.html", location: location, conversations: conversations, my_conversations: my_conversations, teams: teams(conn), dispositions: dispositions
  end

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      changeset: Conversations.get_changeset(),
      location: location,
      teams: teams(conn),
      errors: [])
  end

  def edit(conn, %{"location_id" => location_id, "id" => id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    team_members =
      conn
      |> current_user()
      |> TeamMember.all(location_id)

    conversation =
      conn
      |> current_user()
      |> Conversations.get(id)

    messages =
      conn
      |> current_user()
      |> ConversationMessages.all(id)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Conversations.get_changeset(id, user) do

      render conn, "edit.html",
             location: location,
             conversation: conversation,
             messages: messages,
             team_members: team_members,
             teams: teams(conn),
             changeset: changeset
    end
  end

  def open(conn, %{"conversation_id" => id, "location_id" => location_id}) do
    conversation = Conversations.get(id)
    location =
      conn
      |> current_user()
      |> Location.get(location_id)


    Logger.info("PUT /open for #{id} with status #{conversation.status} ****************")
    Logger.info inspect conn

    if conversation.status == "closed" do

      user_info = Formatters.format_team_member(current_user(conn))

      message = %{"conversation_id" => id,
        "phone_number" => current_user(conn).phone_number,
        "message" => "OPENED: Opened by #{user_info}",
        "sent_at" => DateTime.utc_now()}

      Logger.info "OPENING #{id}"

      with {:ok, _pi} <- Conversations.update(%{"id" => id, "status" => "pending"}),
           {:ok, saved} <- ConversationMessages.create(message) do

        Logger.info inspect saved

        pending_message_count = (ConCache.get(:session_cache, id) || 0)
        :ok = ConCache.put(:session_cache, id, pending_message_count + 1)

        redirect(conn, to: team_location_conversation_conversation_message_path(conn, :index, location.team_id, location.id, id))
      else
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Unable to open conversation")
          |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location_id))
      end
    else

      redirect(conn, to: team_location_conversation_conversation_message_path(conn, :index, location.team_id, location.id, id))
    end
  end

  def close(conn, %{"conversation_id" => id, "location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    conversation = Conversations.get(id)

    if conversation.status != "closed" do
      user_info = Formatters.format_team_member(current_user(conn))

      _ = ConCache.delete(:session_cache, id)

      message = if params["disposition_id"] do
        Data.ConversationDisposition.create(%{"conversation_id" => id, "disposition_id" => params["disposition_id"]})

        disposition =
          conn
          |> current_user()
          |> Data.Disposition.get(params["disposition_id"])

        %{"conversation_id" => id,
          "phone_number" => current_user(conn).phone_number,
          "message" => "CLOSED: Closed by #{user_info} with disposition #{disposition.disposition_name}",
          "sent_at" => DateTime.utc_now()}
      else
        %{"conversation_id" => id,
          "phone_number" => current_user(conn).phone_number,
          "message" => "CLOSED: Closed by #{user_info}",
          "sent_at" => DateTime.utc_now()}
      end

      with {:ok, _pi} <- Conversations.update(%{"id" => id, "status" => "closed", "team_member_id" => nil}),
           {:ok, _} <- ConversationMessages.create(message) do

        redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location_id))
      else
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Unable to close conversation")
          |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location_id))
      end
    else

      redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    end

  end

  def create(conn, %{"location_id" => location_id, "conversation" => %{"campaign_name" => campaign_name} = params}) when campaign_name != "" do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    send_at_utc = if params["scheduled"] && params["send_at"] do
      offest =
        location.timezone
        |> TimezoneOffset.calculate()
        |> abs()

      params["send_at"]
      |> Kernel.<>(":00")
      |> NaiveDateTime.from_iso8601!()
      |> NaiveDateTime.add(offest, :second)
      |> DateTime.from_naive!("Etc/UTC")
    else
      DateTime.utc_now
    end

    scheduled = if params["scheduled"], do: true, else: false

    with %{"send_at" => ^send_at_utc} = params <- Map.put(params, "send_at", send_at_utc),
         %{} = params <- Map.merge(params, %{"location_id" => location.id, "scheduled" => scheduled}),
         {:ok, campaign} <- Campaign.create(params) do

      params["csv"].path
      |> File.stream!
      |> MyParser.parse_stream
      |> Stream.map(fn [first_name, last_name, phone_number] ->
        %{
          "recipient_name" => "#{first_name} #{last_name}",
          "phone_number" => phone_number,
          "campaign_id" => campaign.id}
      end)
      |> Stream.map(fn(row) -> CampaignRecipient.create(row) end)
      |> Enum.count()

      redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location.id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to create campaign")
        |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    end
  end

  def create(conn, %{"location_id" => location_id, "conversation" => %{"original_number" => original_number}} = params) when original_number != "" do

    current_user=conn
                 |> current_user()
    location =current_user
              |> Location.get(location_id)

    with {:ok, conversation, params}  <- find_or_start_conversation(%{member: original_number,
      message: params["conversation"]["message"],
      location_number: location.phone_number,
      team_member_number: current_user(conn).phone_number})
      do

      res={:ok, conversation, params}
                 |> handle_sending_message()
      AssignTeamMemberController.assign(%{"id" => conversation.id, "location_id" => location_id, "team_member_id" => current_user.team_member.id})
      res
      |> update_conn(conn)
      |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location.id))
    else
      err ->

        conn|> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location.id))
        conn
    end

  end

  defp find_or_start_conversation(%{member: member, location_number: location} = params) do
    member = String.replace(member, "-", "")

    member = if String.length(member) == 10 do
      "+1#{member}"
    else
      member
    end
    case Conversations.find_or_start_conversation({member, location}) do
      {:error, changeset} ->
        {:error, changeset, params}
      {:ok, %Data.Schema.Conversation{} = conversation} ->
        {:ok, conversation, params}
    end
  end

  defp handle_sending_message({:ok, conversation, params}) do
    %{"conversation_id" => conversation.id,
      "phone_number" => params.team_member_number,
      "message" => params.message,
      "sent_at" => Calendar.DateTime.now!("Etc/UTC")
    }
    |> ConversationMessages.create()

    @chatbot.send(%{provider: :twilio, from: params.location_number, to: params.member, body: params.message})

    :ok
  end
  defp handle_sending_message({:error, _, _params}), do: :error

  defp update_conn(:ok, conn), do: put_flash(conn, :success, "Sending message was successful")
  defp update_conn(:error, conn), do: put_flash(conn, :error, "Sending message failed")

end
