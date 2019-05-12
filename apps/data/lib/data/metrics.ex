defmodule Data.Metrics do
  alias Data.Query.ReadOnly.Metrics

  def all_teams(),
    do: Metrics.all_teams()

  def team(team_id),
    do: Metrics.team_metrics_by_team_id(team_id)

end
