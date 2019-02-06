defmodule MainWeb.Intents do
  @moduledoc """
  This module receives the intent and args from Wit and then routes
  the information to the correct intent handler. To add a new intent
  add the module and implement the behaviour. Then add the atom and
  module to the @intents map.
  """

  @callback build_response(List.t, location :: binary) :: String.t

  alias MainWeb.Intents.{
    Address,
    Hours,
    Wifi
  }

  @intents %{
    getAddress: Address,
    # getHours: Hours,
    getWifi: Wifi
  }

  @doc """
  Get the response from the intent module. If the intent hasn't been
  implemented then a default message is returned.
  """
  def get({intent, args}, location) do
    args = remove_intent(args)

    intent
    |> String.to_existing_atom()
    |> fetch_module()
    |> apply(:build_response, [args, location])
  end

  def build_response(args, location),
    do: "Not sure about that. Give me a minute..."

  defp fetch_module(intent) when is_atom(intent),
    do: @intents[intent] || MainWeb.Intents

  defp remove_intent(args) when is_list(args),
    do: Enum.filter(args, fn({key, _}) -> key != :intent end)

end
