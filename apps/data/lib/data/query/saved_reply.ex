defmodule Data.Query.SavedReply do
  @moduledoc """
  Module for the saved reply queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.SavedReply
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a saved reply by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: SavedReply.t() | nil
  def get(id, repo \\ Read) do
    from(t in SavedReply,
      where: t.id == ^id,
      preload: [:location]
    )
    |> repo.one()
  end

  @doc """
  Return a list of active saved_reply for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [SavedReply.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in SavedReply,
      where: t.location_id == ^location_id,
      order_by: t.inserted_at,
      preload: [:location]
    )
    |> repo.all()
  end

  @doc """
  Creates a new saved reply
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, SavedReply.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %SavedReply{}
    |> SavedReply.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing saved_reply
  """
  @spec update(saved_reply :: SavedReply.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, SavedReply.t()} | {:error, Ecto.Changeset.t()}
  def update(%SavedReply{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> SavedReply.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a saved_reply. This is a logical delete
  """
  @spec delete(saved_reply :: SavedReply.t(), repo :: Ecto.Repo.t()) ::
          {:ok, SavedReply.t()} | {:error, :no_record_found}
  def delete(%SavedReply{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %SavedReply{} = saved_reply ->
        repo.delete(saved_reply)

      nil ->
        {:error, :no_record_found}
    end
  end
end
