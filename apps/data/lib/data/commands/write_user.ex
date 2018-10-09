defmodule Data.Commands.WriteUser do
  @moduledoc false

  alias Data.Query.WriteOnly.User, as: Write
  alias Data.Commands.Supervisor, as: Command

  def run(user),
    do: Command.execute_task(fn -> Write.write(user) end)
end
