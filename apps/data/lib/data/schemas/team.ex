defmodule Data.Schema.Team do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
    team_name
    website
  |a

  @optional_fields ~w|
    team_member_count
    deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "teams" do
    field(:team_name, :string)
    field(:website, :string)
    field(:team_member_count, :integer)

    field(:deleted_at, :utc_datetime)

    has_many(:locations, Data.Schema.Location)
    has_many(:team_members, Data.Schema.TeamMember)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
