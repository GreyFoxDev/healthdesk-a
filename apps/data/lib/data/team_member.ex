defmodule Data.TeamMember do
  @moduledoc """
  This is the Team Member API for the data layer
  """
  alias Data.Query.TeamMember, as: Query
  alias Data.Schema.TeamMember, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate associate_locations(one, two), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: Query.get_by_location_id(location_id)

  def all(_, _),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, team_id) when role in @roles,
    do: Query.get_by_team_id(team_id)

  def get_by_location_id(%{role: role}, location_id) when role in @roles,
    do: Query.get_by_location_id(location_id)

  def create(params) do
    {:ok, team_member} = result = Query.create(params)

    if params.locations && params.locations != [] do
      associate_locations(team_member.id, params.locations)
    end

    result
  end

  def update(id, params) do
    result =
      id
      |> Query.get()
      |> Query.update(params)

    if params.locations && params.locations != [] do
      associate_locations(id, params.locations)
    end

    result
  end
end
