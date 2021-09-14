defmodule Chatbot.MessageHandler do
  use GenServer,
    start: {Chatbot.MessageHandler, :start_link, []},
    restart: :transient

  @moduledoc """

  The Message Handler is the process responsible for sending
  the messages to the appropriate client.

  """

  require Logger

  @providers %{
    twilio: Chatbot.Client.Twilio
  }
  @provider_types Map.keys(@providers)

  def start_link(%Chatbot.Params{} = params),
    do: GenServer.start_link(__MODULE__, params)

  def init(params) do
    send(self(), :send_message)
    {:ok, params}
  end

  def handle_info(:send_message, %{provider: provider} = state)
      when provider in @provider_types do
    @providers[provider].call(state)
    {:stop, :normal, state}
  end

  def handle_info(_, state) do
    Logger.error("Unkown provider in message: #{inspect(state)}")
    {:stop, :normal, state}
  end
end
