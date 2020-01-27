defmodule Data.Query.ConversationDisposition do
  @moduledoc """
  Module for the Conversation Disposition queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.ConversationDisposition
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @doc """
  Creates a new conversation disposition
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationDisposition.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ConversationDisposition{}
    |> ConversationDisposition.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
