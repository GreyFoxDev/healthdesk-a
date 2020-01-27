defmodule MainWeb.Intents.Address do
  @moduledoc """
  This module handles the Location Address intent and returns a
  formatted message.
  """

  alias Data.Location

  @address_1 """
  We're located at:
  [address line 1]
  [city], [state] [zip_code]
  """

  @address_2 """
  We're located at:
  [address line 1]
  [address line 2]
  [city], [state] [zip_code]
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response(_args, location) do
    case Location.get_by_phone(location) do
      nil ->
        "Sorry, we don't give that out."
      location ->
        if location.address_2 do
          @address_2
          |> String.replace("[address line 1]", location.address_1)
          |> String.replace("[address line 2]", location.address_2)
          |> String.replace("[city]", location.city)
          |> String.replace("[state]", location.state)
          |> String.replace("[zip_code]", location.postal_code)
        else
          @address_1
          |> String.replace("[address line 1]", location.address_1)
          |> String.replace("[city]", location.city)
          |> String.replace("[state]", location.state)
          |> String.replace("[zip_code]", location.postal_code)
        end
    end
  end

end
