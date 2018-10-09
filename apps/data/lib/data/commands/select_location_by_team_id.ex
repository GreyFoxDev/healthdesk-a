defmodule Data.Commands.SelectLocationByTeamId do
  @moduledoc false

  alias Data.Query.ReadOnly.Location, as: Read
  alias Data.Commands.Supervisor, as: Command

  def run(team_id),
    do: Command.execute_task_with_results(fn -> Read.all(team_id) end)
end
