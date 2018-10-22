defmodule Data.Commands.NormalHours do
  @moduledoc false

  use Data.Commands, schema: NormalHours

  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)
end
