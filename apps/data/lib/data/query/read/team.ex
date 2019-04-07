defmodule Data.Query.ReadOnly.Team do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Team
  alias Data.ReadOnly.Repo

  def all do
    from(t in Team,
      where: is_nil(t.deleted_at),
      left_join: l in assoc(t, :locations),
      left_join: m in assoc(t, :team_members),
      left_join: c in assoc(l, :conversations),
      preload: [locations: {l, conversations: c}, team_members: m],
      order_by: [t.team_name, l.location_name, c.started_at]
    )
    |> Repo.all()
  end

  def team_with_locations(team_id) do
    from(t in Team,
      where: t.id == ^team_id,
      left_join: l in assoc(t, :locations),
      left_join: m in assoc(t, :team_members),
      where: is_nil(l.deleted_at),
      preload: [:locations, :team_members],
      order_by: [t.team_name, l.location_name],
      limit: 1
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Team, id)
end
