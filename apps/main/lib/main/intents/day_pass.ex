defmodule MainWeb.Intents.DayPass do
  @moduledoc """
  This module handles the Daily Pass intent and returns a
  formatted message
  """

  alias Data.{
    PricingPlan,
    Location
  }

  require Logger

  @pass """
  Our day pass is $[day_pass_price]. Please visit our front desk to purchase. Is there anything else we can assist you with?
  """

  @no_pass """
  Unfortunately, we don't offer a day pass. Is there anything else we can assist you with?
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response(_args, location) do
    location = Location.get_by_phone(location)
    case PricingPlan.price_plans(:daily, location.id) do
      nil ->
        @no_pass

      %{pass_price: pass_price} ->
        String.replace(@pass, "[day_pass_price]", pass_price)

      {:error, reason} ->
        Logger.error reason
        @no_pass
    end
  end

end
