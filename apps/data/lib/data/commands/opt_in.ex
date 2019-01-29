defmodule Data.Commands.OptIn do
  @moduledoc false

  use Data.Commands, schema: OptIn

  def by_phone_number(phone_number),
    do: Command.execute_task_with_results(fn -> Read.get_by_phone(phone_number) end)
end
