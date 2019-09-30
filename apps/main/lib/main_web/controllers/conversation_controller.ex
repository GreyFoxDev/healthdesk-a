defmodule MainWeb.ConversationController do
  use MainWeb.SecuredContoller

  alias Data.{Commands.Conversations, ConversationMessages, Location, TeamMember, Member}
  alias MainWeb.Helper.Formatters

  require Logger

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def index(conn, %{"location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    conversations =
      conn
      |> current_user()
      |> Data.Conversations.all(location_id)

    my_conversations =
      Enum.filter(conversations, fn(c) -> c.team_member && c.team_member.user_id == current_user(conn).id end)

    render conn, "index.html", location: location, conversations: conversations, my_conversations: my_conversations, teams: teams(conn)
  end

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      changeset: Data.Conversations.get_changeset(),
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
      |> Data.Conversations.get(id)

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
    location =
      conn
      |> current_user()
      |> Location.get(location_id)


    user_info = Formatters.format_team_member(current_user(conn))

    message = %{"conversation_id" => id,
                "phone_number" => current_user(conn).phone_number,
                "message" => "OPENED: Opened by #{user_info}",
                "sent_at" => DateTime.utc_now()}


    with {:ok, _pi} <- Data.Conversations.update(%{"id" => id, "status" => "open"}),
         {:ok, _} <- ConversationMessages.create(message) do

      redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to open conversation")
        |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    end
  end

  def close(conn, %{"conversation_id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    user_info = Formatters.format_team_member(current_user(conn))
    message = %{"conversation_id" => id,
                "phone_number" => current_user(conn).phone_number,
                "message" => "CLOSED: Closed by #{user_info}",
                "sent_at" => DateTime.utc_now()}

    with {:ok, _pi} <- Data.Conversations.update(%{"id" => id, "status" => "closed", "team_member_id" => nil}),
         {:ok, _} <- ConversationMessages.create(message) do

      redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to close conversation")
        |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    end
  end

  def create(conn, %{"location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    %{member: params["conversation"]["original_number"],
      message: params["conversation"]["message"],
      location_number: location.phone_number,
      team_member_number: current_user(conn).phone_number}
      |> find_or_start_conversation()
      |> handle_sending_message()
      |> update_conn(conn)
      |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location.id))
  end

  defp find_or_start_conversation(%{member: member, location_number: location} = params) do
    member = String.replace(member, "-", "")

    member = if length(member) == 10 do
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
  defp handle_sending_message({:error, _, params}), do: :error

  defp update_conn(:ok, conn), do: put_flash(conn, :success, "Sending message was successful")
  defp update_conn(:error, conn), do: put_flash(conn, :error, "Sending message failed")
end
