defmodule Data.Commands.ListUsers do
  @moduledoc false

  alias Data.Query.ReadOnly.User, as: Read
  alias Data.Commands.Supervisor, as: Command

  def run,
    do: Command.execute_task_with_results(fn -> Read.all() end)
end
