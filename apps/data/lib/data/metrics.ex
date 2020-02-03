defmodule Data.Metrics do
  alias Data.Query.Metrics

  def all_teams(),
    do: Metrics.all_teams()

  def team(team_id),
    do: Metrics.get_by_team_id(team_id)
end
