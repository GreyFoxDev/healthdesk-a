defmodule Data.Commands.ConversationMessages do
  @moduledoc false

  use Data.Commands, schema: ConversationMessage

  def all(conversation_id),
    do: Command.execute_task_with_results(fn -> Read.all(conversation_id) end)
end
