defmodule Data.Query.ReadOnly.ConversationMessage do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{ConversationMessage, User}
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(ConversationMessage)

  def all(conversation_id) do
    from(c in ConversationMessage,
      where: c.conversation_id == ^conversation_id,
      order_by: c.sent_at
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Conversation, id)
end
