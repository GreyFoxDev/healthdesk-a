defmodule Data.Commands.TeamMember do
  @moduledoc false

  use Data.Commands, schema: TeamMember

  def all(team_id),
    do: Command.execute_task_with_results(fn -> Read.all(team_id) end)

  def get_by_location(location_id),
    do: Command.execute_task_with_results(fn -> Read.get_by_location(location_id) end)
end
