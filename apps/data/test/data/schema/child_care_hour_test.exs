defmodule Data.Schema.ChildCareHourTest do
  use ExUnit.Case

  alias Data.Schema.ChildCareHour

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = ChildCareHour.changeset(%ChildCareHour{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             ChildCareHour.changeset(%ChildCareHour{}, %{location_id: UUID.uuid4()})
  end
end
