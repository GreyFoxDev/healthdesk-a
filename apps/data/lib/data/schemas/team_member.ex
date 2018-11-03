defmodule Data.Schema.TeamMember do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  user_id
  team_id
  |a

  @optional_fields ~w|
  location_id
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "team_members" do
    belongs_to(:team, Data.Schema.Team)
    belongs_to(:location, Data.Schema.Location)
    belongs_to(:user, Data.Schema.User)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
