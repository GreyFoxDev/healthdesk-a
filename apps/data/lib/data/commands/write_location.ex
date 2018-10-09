defmodule Data.Commands.WriteLocation do
  @moduledoc false

  alias Data.Query.WriteOnly.Location, as: Write
  alias Data.Commands.Supervisor, as: Command

  def run(location),
    do: Command.execute_task(fn -> Write.write(location) end)

  def run(orig_location, location),
    do: Command.execute_task(fn -> Write.write(orig_location, location) end)
end
