defmodule Data.Schema.TeamMemberTest do
  use ExUnit.Case

  alias Data.Schema.TeamMember

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = TeamMember.changeset(%TeamMember{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]},
             team_id: {"can't be blank", [validation: :required]},
             user_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             TeamMember.changeset(%TeamMember{}, %{
               location_id: UUID.uuid4(),
               team_id: UUID.uuid4(),
               user_id: UUID.uuid4()
             })
  end
end
