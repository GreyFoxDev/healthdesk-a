defmodule Data.Commands.Authenticate do
  @moduledoc false

  alias Data.Query.ReadOnly.User, as: Read
  alias Data.Commands.Supervisor, as: Command

  def run(%{phone_number: phone_number}),
    do: Command.execute_task_with_results(fn -> Read.get_by_phone(phone_number) end)
end
