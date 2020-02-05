defmodule MainWeb.Intents.Wifi do
  @moduledoc """
  This module handles the WifiNetwork intent and returns a
  formatted message.
  """

  alias Data.{
    WifiNetwork,
    Location
  }

  @free_wifi """
  Free WiFi:
  Network: [wifi_name]
  Password: [wifi_password]

  Is there anything else we can assist you with?
  """

  @no_wifi """
  Unfortunately, we don't offer free WiFi. Is there anything else we can assist you with?
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response(_args, location) do
    location = Location.get_by_phone(location)

    location.id
    |> WifiNetwork.get_by_location_id()
    |> case do
      [] ->
        @no_wifi

      [wifi] ->
        @free_wifi
        |> String.replace("[wifi_name]", wifi.network_name)
        |> String.replace("[wifi_password]", wifi.network_pword)

    end
  end

end
