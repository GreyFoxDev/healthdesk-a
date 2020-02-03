defmodule Data.Schema.TeamMemberLocation do
  @moduledoc """
  The schema for associating team members with multiple locations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          team_member_id: binary()
        }

  @required_fields ~w|
  location_id
  team_member_id
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
