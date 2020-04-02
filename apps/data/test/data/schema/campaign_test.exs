defmodule Data.Schema.CampaignTest do
  use ExUnit.Case

  alias Data.Schema.Campaign

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = Campaign.changeset(%Campaign{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             Campaign.changeset(%Campaign{}, %{location_id: UUID.uuid4()})
  end
end
