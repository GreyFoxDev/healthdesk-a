defmodule Session.Actions do

  @moduledoc false

  require Logger

  @default_error "Not sure about that. Give me a minute...\n"

  def ask_question(question) do
    WitClient.MessageSupervisor.ask_question(self(), question)
    receive do
      {:response, :unknown} ->
        "HELP"
      {:response, response} ->
        response
      {:error, _error} ->
        "HELP"
    end
  end

  @doc """
  Send request to be logged. returns `{:ok, result}`
  """
  def log(%{request: request} = session, direction, _deps) do
    %{
      direction: direction,
      command: (session.current_command || "UNKNOWN"),
      message: request.body,
      from: request.from,
      to: request.to
    }
    |> inspect()
    |> Logger.info()

    session
  end

  @doc """
  Send message to chatbot
  """
  def send_message(nil, _deps), do: nil
  def send_message(response, deps),
    do: deps.chatbot.send(response)

  @doc """
  build the message to send
  """
  def build_message(nil, _), do: nil
  def build_message(body, %{provider: provider, from: from, to: to}) do
    %{
      provider: provider,
      body: """
      #{body}
      """,
      to: from,
      from: to}
  end

  def start_or_update_conversation(%Session{request: request}) do
    with nil <- Data.Commands.Conversations.get_by_phone(request.from),
         %Data.Schema.Location{} = location <- Data.Commands.Location.get_by_phone(request.to) do
      %{
        "location_id" => location.id,
        "original_number" => request.from,
        "status" => "open",
        "started_at" => DateTime.utc_now()
      }
      |> Data.Commands.Conversations.write()

      :timer.sleep(1000)

      conversation = Data.Commands.Conversations.get_by_phone(request.from)

      %{
        "phone_number" => request.from,
        "message" => request.body,
        "sent_at" => DateTime.utc_now(),
        "conversation_id" => conversation.id}
      |> Data.Commands.ConversationMessages.write()

      {:new, conversation}
    else
      %Data.Schema.Conversation{status: "closed"} = conversation ->
        %{
          "phone_number" => request.from,
          "message" => request.body,
          "status" => "open",
          "sent_at" => DateTime.utc_now(),
          "conversation_id" => conversation.id}
        |> Data.Commands.ConversationMessages.write()

        {:reopen, conversation}
      %Data.Schema.Conversation{status: "open"} = conversation ->
        %{
          "phone_number" => request.from,
          "message" => request.body,
          "sent_at" => DateTime.utc_now(),
          "conversation_id" => conversation.id}
        |> Data.Commands.ConversationMessages.write()

        {:open, conversation}
    end
  end

  def update_conversation(%{body: body} = message, conversation) when body == @default_error do
    %{
      "phone_number" => message.from,
      "message" => @default_error,
      "sent_at" => DateTime.utc_now(),
      "conversation_id" => conversation.id} |> Data.Commands.ConversationMessages.write()

    message
  end

  def update_conversation(%{body: body, from: from} = message, conversation) do
    %{
      "phone_number" => from,
      "message" => body,
      "sent_at" => DateTime.utc_now(),
      "conversation_id" => conversation.id} |> Data.Commands.ConversationMessages.write()

    Data.Commands.Conversations.write(conversation, %{"status" => "closed"})

    message
  end
end
