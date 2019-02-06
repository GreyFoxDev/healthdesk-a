defmodule MainWeb.Intents.Wifi do
  @moduledoc """
  This module handles the WifiNetwork intent and returns a
  formatted message.
  """

  alias Data.Commands.WifiNetwork

  @free_wifi """
  Free WiFi:
  Network: [wifi_name]
  Password: [wifi_password]
  """

  @no_wifi """
  Unfortunately, we don't offer free WiFi.
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response(_args, location) do
    case WifiNetwork.get_by_phone(location) do
      nil ->
        @no_wifi

      wifi ->
        @free_wifi
        |> String.replace("[wifi_name]", wifi.network_name)
        |> String.replace("[wifi_password]", wifi.network_pword)

    end
  end

end
