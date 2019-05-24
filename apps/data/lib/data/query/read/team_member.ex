defmodule Data.Query.ReadOnly.TeamMember do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{TeamMember, User, TeamMemberLocation}
  alias Data.ReadOnly.Repo

  def all do
    from(t in TeamMember,
      join: u in User,
      left_join: l in assoc(t, :team_member_locations),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      order_by: [u.first_name, u.last_name],
      preload: [locations: l, user: u]
    )
    |> Repo.all()
  end

  def all(team_id) do
    from(t in TeamMember,
      join: u in User,
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: t.team_id == ^team_id,
      order_by: [u.first_name, u.last_name],
      preload: [:team_member_locations, :user]
    )
    |> Repo.all()
  end

  def get(id) do
    from(t in TeamMember,
      join: u in User,
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: t.id == ^id,
      preload: [:team_member_locations, :user],
      limit: 1
    )
    |> Repo.all()
    |> case do
      [] ->
        nil

      [team_member] ->
        team_member
    end
  end

  def get_by_location(location_id) do
    from(t in TeamMember,
      join: u in User,
      left_join: l in assoc(t, :team_member_locations),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: l.location_id == ^location_id or t.location_id == ^location_id,
      order_by: [u.first_name, u.last_name],
      preload: [:team_member_locations, :user]
    )
    |> Repo.all()
  end
end
