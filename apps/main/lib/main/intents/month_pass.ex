defmodule MainWeb.Intents.MonthPass do
  @moduledoc """
  This module handles the Monthly Pass intent and returns a
  formatted message
  """

  alias Data.Commands.{
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
      {:ok, nil} ->
        @no_pass

      {:ok, pass} ->
        String.replace(@pass, "[month_pass_price]", pass.pass_price)

      {:error, reason} ->
        Logger.error reason
        @no_pass
    end
  end

end
