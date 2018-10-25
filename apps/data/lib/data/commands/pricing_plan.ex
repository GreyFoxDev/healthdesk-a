defmodule Data.Commands.PricingPlan do
  @moduledoc false

  use Data.Commands, schema: PricingPlans

  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)
end
