defmodule MainWeb.Intents.WeekPass do
  @moduledoc """
  This module handles the Weekly Pass intent and returns a
  formatted message
  """

  alias Data.Commands.PricingPlan

  require Logger

  @pass """
  Our week pass is $[week_pass_price]. Please visit our front desk to purchase.
  """

  @no_pass """
  Unfortunately, we don't offer a week pass.
  """

  @behaviour MainWeb.Intents

  @impl MainWeb.Intents
  def build_response(_args, location) do
    case PricingPlan.price_plans(:weekly, location) do
      {:ok, nil} ->
        @no_pass

      {:ok, pass} ->
        String.replace(@pass, "[week_pass_price]", pass.pass_price)

      {:error, reason} ->
        Logger.error reason
        @no_pass
    end
  end

end
