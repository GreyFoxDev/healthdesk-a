defmodule WitClient.MessageHandler do
  use GenServer,
      start: {WitClient.MessageHandler, :start_link, []},
      restart: :transient

  alias Data.Team

  @moduledoc """

  The Message Handler is the process responsible for sending
  the messages to the appropriate client.

  """

  require Logger

  # @access_token Application.get_env(:wit_client, :access_token)

  def start_link(from, question, bot_id),
      do: GenServer.start_link(__MODULE__, [from, question, bot_id])

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(args) do
    send(self(), :ask)
    {:ok, args}
  end

  def handle_info(:ask, [from, nil, bot_id]) do
    send(from, {:error, :unknown})
    {:stop, :normal, []}
  end

  def handle_info(:ask, [from, question, bot_id]) do
    question = Inflex.parameterize(question, "%20")
    try do



      case System.cmd("curl", [
        "-H",
        "Authorization: Bearer #{bot_id}",
        "https://api.wit.ai/message?v=20181028&q=#{question}"
      ]) do
        {response, 0} ->
          with %{} = response <- Poison.Parser.parse!(response)["entities"],
               intent <- get_intent(response),
               args <- get_args(response) do
            send(from, {:response, {intent, args}})
          else
            error ->
              Logger.error(inspect(error))
              send(from, {:response, :unknown})
          end

        {error, _code} ->
          send(from, {:error, error})
      end
    rescue
      _ ->
        {:stop, :normal, []}
    end
    {:stop, :normal, []}
  end

  def get_intent(%{"intent" => [%{"value" => value} | _]}), do: value
  def get_intent(%{"thanks" => [%{"value" => "true"} | _]}), do: "getMessageGeneric"
  def get_intent(_response), do: :unknown

  def get_args(%{"thanks" => [%{"value" => "true"} | _]}), do: "thanks"

  def get_args(map) do
    map
    |> Map.keys()
    |> Enum.map(&parse_args(&1, map))
  end

  defp parse_args("datetime" = key, map) do
    map
    |> Map.get(key)
    |> parse_datetime()
    |> set_value(key)
  end

  defp parse_args(key, map) do
    map
    |> Map.get(key)
    |> set_value(key)
  end

  defp set_value(value, "greetings"),
       do: {:greetings, value}

  defp set_value(value, key) do
    try do
      key =
        key
        |> String.downcase()
        |> String.to_existing_atom()

      {key, value}
    rescue
      _error in ArgumentError ->
        Logger.error("Invalid key from Wit.AI: #{inspect(key)} value: #{inspect(value)}")
        {key, value}
    end
  end

  defp parse_datetime([%{"type" => "value", "value" => value} | _]), do: value

  defp parse_datetime([
    %{"type" => "interval", "from" => %{"value" => from}, "to" => %{"value" => to}} | _
  ]),
       do: {from, to}

  defp parse_datetime(_), do: nil

  def handle_info(_, state) do
    Logger.error("Unkown message: #{inspect(state)}")
    {:stop, :normal, state}
  end
end
