defmodule Data.Commands.DeleteLocation do
  @moduledoc false

  alias Data.Query.WriteOnly.Location, as: Write
  alias Data.Commands.Supervisor, as: Command

  def run(id),
    do: Command.execute_task(fn -> Write.delete(id) end)
end
