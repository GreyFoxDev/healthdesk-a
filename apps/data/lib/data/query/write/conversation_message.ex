defmodule Data.Query.WriteOnly.ConversationMessage do
  @moduledoc false

  alias Data.Schema.ConversationMessage
  alias Data.ReadOnly.Repo

  def write(params) do
    %ConversationMessage{}
    |> ConversationMessage.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> ConversationMessage.changeset(params)
    |> Repo.insert_or_update!()
  end
end
