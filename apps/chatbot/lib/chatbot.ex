defmodule Chatbot do
  use GenServer,
    start: {Chatbot, :start_link, []},
    restart: :permanent

  require Logger

  alias Chatbot.{Params, MessageSupervisor}

  def start_link,
    do: GenServer.start_link(__MODULE__, [], name: Chatbot)

  def init(_args),
    do: {:ok, %{}}

  @doc """

  Function is called to cast the inbound message to the Chatbot system.

  """
  def send(%{provider: _, from: from, to: to, body: body})
      when is_nil(from) or is_nil(to) or is_nil(body),
      do: {:error, :missing_params}

  def send(params) do
    GenServer.cast(Chatbot, {:inbound, params})
  end

  def handle_cast({:inbound, params}, state) do
    Logger.info("sending message...")

    with {:ok, params} <- Params.build(params),
         {:ok, pid} when is_pid(pid) <- MessageSupervisor.send_message(params) do
      Logger.info("message sent...")
    else
      error ->
        Logger.error("Unable to send message for: #{inspect(params)}")
    end

    {:noreply, state}
  end
end
