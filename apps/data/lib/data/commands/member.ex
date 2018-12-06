defmodule Data.Commands.Member do
  @moduledoc false

  use Data.Commands, schema: Member

  def all(team_id),
    do: Command.execute_task_with_results(fn -> Read.all(team_id) end)
end
