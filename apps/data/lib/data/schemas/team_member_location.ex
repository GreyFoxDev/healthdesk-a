defmodule Data.Schema.TeamMemberLocation do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  team_member_id
  location_id
  |a

  schema "team_member_locations" do
    belongs_to(:team_member, Data.Schema.TeamMember)
    belongs_to(:location, Data.Schema.Location)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
