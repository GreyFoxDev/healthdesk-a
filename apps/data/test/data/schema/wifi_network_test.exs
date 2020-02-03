defmodule Data.Schema.WifiNetworkTest do
  use ExUnit.Case

  alias Data.Schema.WifiNetwork

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = WifiNetwork.changeset(%WifiNetwork{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             WifiNetwork.changeset(%WifiNetwork{}, %{location_id: UUID.uuid4()})
  end
end
