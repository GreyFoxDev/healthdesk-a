defmodule Data.Query.ReadOnly.Team do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Team
  alias Data.ReadOnly.Repo

  def all do
    from(t in Team,
      where: is_nil(t.deleted_at),
      left_join: l in assoc(t, :locations),
      left_join: c in assoc(l, :conversations),
      preload: [locations: {l, conversations: c}],
      order_by: [t.team_name, l.location_name, c.started_at]
    )
    |> Repo.all()
  end

  def team_with_locations(team_id) do
    from(t in Team,
      where: t.id == ^team_id,
      left_join: l in assoc(t, :locations),
      preload: [:locations],
      order_by: [t.team_name, l.location_name]
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Team, id)
end
