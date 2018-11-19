defmodule Data.Query.WriteOnly.Conversation do
  @moduledoc false

  alias Data.Schema.Conversation
  alias Data.ReadOnly.Repo

  def write(params) do
    %Conversation{}
    |> Conversation.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> Conversation.changeset(params)
    |> Repo.insert_or_update!()
  end
end
