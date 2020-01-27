defmodule Data.Query.WriteOnly.TeamMember do
  @moduledoc false

  alias Data.Schema.{TeamMember, TeamMemberLocation}
  alias Data.WriteOnly.Repo

  import Ecto.Query, only: [from: 2]

  def write(params) do
    %TeamMember{}
    |> TeamMember.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> TeamMember.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end

  def associate_locations(id, locations) do
    from(m in TeamMemberLocation, where: m.team_member_id == ^id) |> Repo.delete_all()

    Enum.map(locations, fn location ->
      %TeamMemberLocation{}
      |> TeamMemberLocation.changeset(%{location_id: location, team_member_id: id})
      |> Repo.insert!()
    end)
  end
end
