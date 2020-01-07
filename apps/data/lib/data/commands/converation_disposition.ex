defmodule Data.Commands.ConversationDisposition do
  @moduledoc false

  use Data.Commands, schema: ConversationDisposition

  def all(team_id),
    do: Command.execute_task_with_results(fn -> Read.all(team_id) end)
end
