defmodule Data.Schema.TeamMemberLocationTest do
  use ExUnit.Case

  alias Data.Schema.TeamMemberLocation

  test "validate required fields" do
    assert %{valid?: false, errors: errors} =
             TeamMemberLocation.changeset(%TeamMemberLocation{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]},
             team_member_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             TeamMemberLocation.changeset(%TeamMemberLocation{}, %{
               location_id: UUID.uuid4(),
               team_member_id: UUID.uuid4()
             })
  end
end
