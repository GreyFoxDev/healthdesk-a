defmodule Data.Commands.SelectLocation do
  @moduledoc false

  alias Data.Query.ReadOnly.Location, as: Read
  alias Data.Commands.Supervisor, as: Command

  def run(id),
    do: Command.execute_task_with_results(fn -> Read.get(id) end)
end
