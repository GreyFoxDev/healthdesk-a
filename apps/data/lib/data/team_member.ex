defmodule Data.TeamMember do
  alias Data.Commands.TeamMember

  @roles ["admin", "teammate", "location-admin", "team-admin"]

  import Data.Query.WriteOnly.TeamMember, only: [associate_locations: 2]

  def get_changeset() do
    Data.Schema.TeamMember.changeset(%Data.Schema.TeamMember{})
  end

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> TeamMember.get()
      |> Data.Schema.TeamMember.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: TeamMember.all()

  def all(%{role: role}, location_id) when role in @roles,
    do: TeamMember.get_by_location(location_id)

  def all(_, _),
    do: {:error, :invalid_permissions}

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: TeamMember.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, id) when role in @roles,
    do: TeamMember.all(id)

  def get_by_location_id(%{role: role}, id) when role in @roles,
    do: TeamMember.get_by_location(id)

  def create(params) do
    {:ok, team_member} = result = TeamMember.write(params)

    if params.locations != [] do
      associate_locations(team_member.id, params.locations)
    end

    result
  end

  def update(id, params) do
    result = id
    |> TeamMember.get()
    |> TeamMember.write(params)

    if params.locations != [] do
      associate_locations(id, params.locations)
    end

    result
  end
end
