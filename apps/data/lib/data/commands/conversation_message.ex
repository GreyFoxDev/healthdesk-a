defmodule Data.Commands.ConversationMessages do
  @moduledoc """
  Commands for Conversation Messages
  """

  use Data.Commands, schema: ConversationMessage

  @doc """
  Gets all the conversation messages for a conversation using the conversation id
  """
  @spec all(location_id :: binary) :: list()
  def all(conversation_id),
    do: Command.execute_task_with_results(fn -> Read.all(conversation_id) end)

  def write_new_message(conversation_id, phone_number, message) do
    write(%{
      "conversation_id" => conversation_id,
      "phone_number" => phone_number,
      "message" => message,
      "sent_at" => DateTime.utc_now()
    })
  end
end
