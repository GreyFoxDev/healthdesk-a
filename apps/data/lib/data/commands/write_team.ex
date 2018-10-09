defmodule Data.Commands.WriteTeam do
  @moduledoc false

  alias Data.Query.WriteOnly.Team, as: Write
  alias Data.Commands.Supervisor, as: Command

  def run(team),
    do: Command.execute_task(fn -> Write.write(team) end)

  def run(orig_team, team),
    do: Command.execute_task(fn -> Write.write(orig_team, team) end)
end
