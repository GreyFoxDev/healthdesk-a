defmodule Data.Commands.ChildCareHours do
  @moduledoc false

  use Data.Commands, schema: ChildCareHours

  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)
end
