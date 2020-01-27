defmodule Data.Schema.TeamMember do
  @moduledoc """
  The schema for a team's team members. The location is the team member's default location
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          team_id: binary(),
          user_id: binary(),
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  team_id
  user_id
  |a

  @optional_fields ~w|
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "team_members" do
    field(:deleted_at, :utc_datetime)

    belongs_to(:team, Data.Schema.Team)
    belongs_to(:user, Data.Schema.User)
    belongs_to(:location, Data.Schema.Location)

    has_many(:team_member_locations, Data.Schema.TeamMemberLocation)
    has_many(:locations, through: [:team_member_locations, :locations])
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
