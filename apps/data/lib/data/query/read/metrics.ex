defmodule Data.Query.ReadOnly.Metrics do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.MetricsTeam
  alias Data.ReadOnly.Repo

  def all_teams do
    Repo.all(MetricsTeam)
  end

  def team_metrics_by_team_id(team_id) do
    Repo.get_by(MetricsTeam, team_id: team_id)
  end
end
