defmodule MainWeb.ConversationController do
  use MainWeb.SecuredContoller

  alias Data.{Conversations, ConversationMessages, Location, TeamMember, Member}

  require Logger

  def index(conn, %{"location_id" => location_id} = params) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)


    conversations =
      conn
      |> current_user()
      |> Conversations.all(location_id)

    render conn, "index.html", location: location, conversations: conversations, teams: teams(conn)
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

  def create(conn, %{"location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    conn = params["conversation"]
    |> Map.merge(%{"location_id" => location_id, "status" => "open", "started_at" => DateTime.utc_now()})
    |> Conversations.create()
    |> case do
         %Data.Schema.Conversation{} = conversation ->
           %{"conversation_id" => conversation.id,
             "phone_number" => current_user(conn).phone_number,
             "message" => params["conversation"]["message"],
             "sent_at" => conversation.started_at}
           |> ConversationMessages.create()

           message = %{provider: :twilio, from: location.phone_number, to: params["conversation"]["original_number"], body: params["conversation"]["message"]}
           @chatbot.send(message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end

    redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location.id))
  end

  def update(conn, params) do
  end

  def open(conn, %{"conversation_id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    message = %{"conversation_id" => id,
                "phone_number" => current_user(conn).phone_number,
                "message" => "OPENED: Opened by #{current_user(conn).last_name}",
                "sent_at" => DateTime.utc_now()}


    with {:ok, _pi} <- Conversations.update(%{"id" => id, "status" => "open"}),
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

    message = %{"conversation_id" => id,
                "phone_number" => current_user(conn).phone_number,
                "message" => "CLOSED: Closed by #{current_user(conn).last_name}",
                "sent_at" => DateTime.utc_now()}

    with {:ok, _pi} <- Conversations.update(%{"id" => id, "status" => "closed"}),
         {:ok, _} <- ConversationMessages.create(message) do

      redirect(conn, to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to close conversation")
        |> redirect(to: team_location_conversation_path(conn, :index, location.team_id, location_id))
    end
  end
end
