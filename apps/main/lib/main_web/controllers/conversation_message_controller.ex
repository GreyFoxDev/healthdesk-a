defmodule MainWeb.ConversationMessageController do
  use MainWeb.SecuredContoller

  alias Data.{ConversationMessages, Conversations, Location, MemberChannel, TeamMember}
  alias Data.Schema.MemberChannel, as: Channel

  require Logger

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def index(conn, %{"location_id" => location_id, "conversation_id" => conversation_id}) do
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
      |> fetch_member()

    messages =
      conn
      |> current_user()
      |> ConversationMessages.all(conversation_id)

    dispositions =
      conn
      |> current_user()
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Stream.reject(&(&1.disposition_name in ["Automated", "Call deflected"]))
      |> Stream.map(&({&1.disposition_name, &1.id}))
      |> Enum.to_list()

    render conn, "index.html",
      location: location,
      conversation: conversation,
      messages: messages,
      team_members: team_members,
      teams: teams(conn),
      dispositions: dispositions,
      has_sidebar: True,
      changeset: ConversationMessages.get_changeset()
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
    |> IO.inspect(label: "CONVERSATION")
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

    from_name = if conversation.team_member do
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
           Chatbot.Client.Twilio.channel(message)
           put_flash(conn, :success, "Sending message was successful")
         {:error, _changeset} ->
           put_flash(conn, :error, "Sending message failed")
       end
  end

  defp send_message(%{original_number: << "APP", _ :: binary >>} = conversation, conn, params, location) do
    user = current_user(conn)

    from = if conversation.team_member do
      Enum.join([conversation.team_member.user.first_name, "#{String.first(conversation.team_member.user.last_name)}."], " ")
    else
      location.location_name
    end

    params["conversation_message"]
    |> Map.merge(%{"conversation_id" => conversation.id, "phone_number" => user.phone_number, "sent_at" => DateTime.utc_now()})
    |> ConversationMessages.create()
    |> case do
         {:ok, message} ->
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
