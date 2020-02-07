defmodule MainWeb.Intents.MonthPass do
  @moduledoc """
  This module handles the Monthly Pass intent and returns a
  formatted message
  """

  alias Data.{
    PricingPlan,
    Location
  }

  require Logger

  @pass """
  Our month pass is $[month_pass_price]. Please visit our front desk to purchase. Is there anything else we can assist you with?
  """

  @no_pass """
  Unfortunately, we don't offer a month pass. Is there anything else we can assist you with?
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response(_args, location) do
    location = Location.get_by_phone(location)
    case PricingPlan.price_plans(:monthly, location.id) do
      nil ->
        @no_pass

      %{pass_price: pass_price} ->
        String.replace(@pass, "[month_pass_price]", pass_price)

      {:error, reason} ->
        Logger.error reason
        @no_pass
    end
  end

end
