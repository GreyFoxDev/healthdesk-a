defmodule Data.Query.WriteOnly.ConversationDisposition do
  @moduledoc false

  alias Data.Schema.ConversationDisposition
  alias Data.WriteOnly.Repo

  def write(params) do
    %ConversationDisposition{}
    |> ConversationDisposition.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> ConversationDisposition.changeset(params)
    |> Repo.insert_or_update!()
  end
end
