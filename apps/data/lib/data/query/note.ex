defmodule Data.Query.Note do
  @moduledoc """
  Module for the Note queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Note
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @spec get_by_conversation(conversation_id :: binary(), repo :: Ecto.Repo.t()) :: [Note.t()]
  def get_by_conversation(conversation_id, repo \\ Read) do
    from(n in Note,
      where: n.conversation_id == ^conversation_id,
      order_by: [asc: n.inserted_at],
      preload: [:user, :conversation]
    )
    |> repo.all()
  end

  @doc """
  Creates a new Note
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Note.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Note{}
    |> Note.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing Note
  """
  @spec update(notification :: Note.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Note.t()} | {:error, Ecto.Changeset.t()}
  def update(%Note{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Note.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
