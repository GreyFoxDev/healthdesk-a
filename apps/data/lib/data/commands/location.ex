defmodule Data.Commands.Location do
  @moduledoc false

  use Data.Commands, schema: Location

  def all(team_id),
    do: Command.execute_task_with_results(fn -> Read.all(team_id) end)

  def get_by_phone(phone_number),
    do: Read.get_by_phone(phone_number)

  def get_by_api_key(key),
    do: Read.get_by_api_key(key)
end
