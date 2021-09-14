defmodule MainWeb.ConversationMessageController do
  use MainWeb.SecuredContoller

  alias Data.{ConversationMessages, Conversations, Location, MemberChannel, Team}
  alias Data.Schema.MemberChannel, as: Channel

  require Logger

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def index(conn, %{"location_id" => location_id, "conversation_id" => conversation_id}) do
    user = conn
           |> current_user()
    live_render(conn, MainWeb.Live.ConversationsView, session: %{"location_id" => location_id,"conversation_id" => conversation_id, "user" => user})
  end

  def fetch_member(%{original_number: << "CH", _rest :: binary >> = channel} = conversation) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel) do
      Map.put(conversation, :member, channel.member)
    end
  end
  def fetch_member(conversation), do: conversation

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

  defp send_message(%{original_number: << "+", _ :: binary >>} = conversation, conn, params, location) do
    user = current_user(conn)

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %{
             provider: :twilio, from: location.phone_number,
             to: MainWeb.Notify.validate_phone_number(conversation.original_number),
             body: params["conversation_message"]["message"]
           }
           @chatbot.send(message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, _changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp send_message(%{original_number: << "messenger:", _ :: binary>>} = conversation, conn, params, location) do
    user = current_user(conn)

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %Chatbot.Params{provider: :twilio, from: "messenger:#{location.messenger_id}", to: conversation.original_number, body: params["conversation_message"]["message"]}
           Chatbot.Client.Twilio.call(message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, _changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp send_message(%{original_number: << "CH", _ :: binary >>} = conversation, conn, params, location) do
    user = current_user(conn)

    _from_name = if conversation.team_member do
      Enum.join([conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."], " ")
    else
      location.location_name
    end

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           message = %Chatbot.Params{provider: :twilio, from: location.phone_number, to: conversation.original_number, body: params["conversation_message"]["message"]}
           #account_id= Team.get_sub_account_id_by_location_id(location.id)
           Chatbot.Client.Twilio.channel(message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, _changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp send_message(%{original_number: << "APP", _ :: binary >>} = conversation, conn, params, location) do
    user = current_user(conn)

    _from = if conversation.team_member do
      Enum.join([conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."], " ")
    else
      location.location_name
    end

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, _message} ->
           put_flash(conn, :success, "Sending message was successful")
         {:error, _changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp render_page(conn, page, changeset, errors) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
