defmodule Data.Commands.Conversations do
  @moduledoc false

  use Data.Commands, schema: Conversation

  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)

  def get_by_phone(phone_number),
    do: Command.execute_task_with_results(fn -> Read.get_by_phone(phone_number) end)
end
