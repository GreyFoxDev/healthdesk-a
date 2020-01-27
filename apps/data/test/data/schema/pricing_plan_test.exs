defmodule Data.Schema.PricingPlanTest do
  use ExUnit.Case

  alias Data.Schema.PricingPlan

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = PricingPlan.changeset(%PricingPlan{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             PricingPlan.changeset(%PricingPlan{}, %{location_id: UUID.uuid4()})
  end
end
