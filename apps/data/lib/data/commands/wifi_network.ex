defmodule Data.Commands.WifiNetwork do
  @moduledoc false

  use Data.Commands, schema: WifiNetwork

  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)
end
