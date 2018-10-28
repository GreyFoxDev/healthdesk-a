defmodule WitClient.MessageHandler do
  use GenServer,
    start: {WitClient.MessageHandler, :start_link, []},
    restart: :transient

  @moduledoc """

  The Message Handler is the process responsible for sending
  the messages to the appropriate client.

  """

  require Logger

  @access_token Application.get_env(:wit_client, :access_token)

  def start_link(from, question),
    do: GenServer.start_link(__MODULE__, [from, question])

  def init(args) do
    send(self(), :ask)
    {:ok, args}
  end

  def handle_info(:ask, [from, question]) do
    question = Inflex.parameterize(question, "%20")
    case System.cmd "curl", ["-XPOST", "-H", "Authorization: Bearer #{@access_token}", "https://api.wit.ai/message?v=20181028&q=#{question}"] do
      {response, 0} ->
        with %{} = response <- Poison.Parser.parse!(response)["entities"],
             intent <- get_intent(response),
             args <- get_args(response) do

          send(from, {:response, {intent, args}})
        else
          error ->
            Logger.error inspect(error)
            send(from, {:response, :unknown})
        end
      {error, code} ->
        send(from, {:error, error})
    end
    {:stop, :normal, []}
  end

  def get_intent(%{"intent" => [%{"value" => value}|_]}), do: value
  def get_intent(_response), do: :unknown

  def get_args(%{"datetime" => [%{"type" => "value", "value" => value}|_]}), do: value
  def get_args(%{"datetime" => [%{"type" => "interval", "from" => %{"value" => from}, "to" => %{"value" => to}}|_]}), do: {from, to}
  def get_args(_response), do: ""

  def handle_info(_, state) do
    Logger.error "Unkown message: #{inspect state}"
    {:stop, :normal, state}
  end
end
