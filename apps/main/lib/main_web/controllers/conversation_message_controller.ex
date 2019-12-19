defmodule MainWeb.ConversationMessageController do
  use MainWeb.SecuredContoller

  alias Data.{ConversationMessages, Conversations, Location, TeamMember}
  alias MainWeb.Endpoint

  require Logger

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def index(conn, %{"location_id" => location_id, "conversation_id" => conversation_id} = params) do
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
      |> Conversations.get(conversation_id)

    messages =
      conn
      |> current_user()
      |> ConversationMessages.all(conversation_id)

    render conn, "index.html",
      location: location,
      conversation: conversation,
      messages: messages,
      team_members: team_members,
      teams: teams(conn),
      has_sidebar: True,
      changeset: ConversationMessages.get_changeset()
  end

  def create(conn, %{"location_id" => location_id, "conversation_id" => conversation_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    conn
    |> current_user()
    |> Conversations.get(conversation_id)
    |> send_message(conn, params, location)
    |> redirect(to: team_location_conversation_conversation_message_path(conn, :index, location.team_id, location.id, conversation_id))
  end

  defp send_message(%{original_number: << "+1", _ :: binary >>} = conversation, conn, params, location) do
    user = current_user(conn)

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %{provider: :twilio, from: location.phone_number, to: conversation.original_number, body: params["conversation_message"]["message"]}
           Logger.info "Message created ************* #{inspect @chatbot} #{inspect message}"
           @chatbot.send(message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp send_message(conversation, conn, params, location) do
    user = current_user(conn)

    [web_location] = Location.get_by_team_id(user, location.team_id) |> Enum.filter(&(&1.web_chat))

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %Chatbot.Params{provider: :twilio, from: location.phone_number, to: conversation.original_number, body: params["conversation_message"]["message"]}
           Logger.info "Message created ************* #{inspect @chatbot} #{inspect message}"
           Chatbot.Client.Twilio.channel(message)
           put_flash(conn, :success, "Sending message was successful")

           # Endpoint.broadcast("web_bot:#{conversation.original_number}", "reply", message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
