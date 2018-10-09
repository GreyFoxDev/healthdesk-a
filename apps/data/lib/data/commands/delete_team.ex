defmodule Data.Commands.DeleteTeam do
  @moduledoc false

  alias Data.Query.WriteOnly.Team, as: Write
  alias Data.Commands.Supervisor, as: Command

  def run(id),
    do: Command.execute_task(fn -> Write.delete(id) end)
end
