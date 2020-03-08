defmodule Data.Query.ConversationMessage do
  @moduledoc """
  Module for the Conversation Message queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.ConversationMessage
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @doc """
  Returns a conversation message by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: ConversationMessage.t() | nil
  def get(id, repo \\ Read) do
    from(t in ConversationMessage,
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of conversation messages for a conversation
  """
  @spec get_by_conversation_id(conversation_id :: binary(), repo :: Ecto.Repo.t()) :: [
          ConversationMessage.t()
        ]
  def get_by_conversation_id(conversation_id, repo \\ Read) do
    from(c in ConversationMessage,
      where: c.conversation_id == ^conversation_id,
      distinct: [c.sent_at, c.message],
      order_by: c.sent_at,
      select: c
    )
    |> repo.all()
  end

  @doc """
  Creates a new conversation message
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationMessage.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ConversationMessage{}
    |> ConversationMessage.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
