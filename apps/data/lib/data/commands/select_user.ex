defmodule Data.Commands.SelectUser do
  @moduledoc false

  alias Data.Query.ReadOnly.User, as: Read
  alias Data.Commands.Supervisor, as: Command

  def run(id),
    do: Command.execute_task_with_results(fn -> Read.get(id) end)
end
