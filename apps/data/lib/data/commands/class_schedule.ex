defmodule Data.Commands.ClassSchedule do
  @moduledoc false

  use Data.Commands, schema: ClassSchedule

  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)
end
