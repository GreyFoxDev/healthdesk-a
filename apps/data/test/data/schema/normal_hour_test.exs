defmodule Data.Schema.NormalHourTest do
  use ExUnit.Case

  alias Data.Schema.NormalHour

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = NormalHour.changeset(%NormalHour{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             NormalHour.changeset(%NormalHour{}, %{location_id: UUID.uuid4()})
  end
end
