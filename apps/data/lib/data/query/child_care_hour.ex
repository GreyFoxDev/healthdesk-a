defmodule Data.Query.ChildCareHour do
  @moduledoc """
  Module for the Child Care Hour queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.ChildCareHour
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a child care hour record by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: ChildCareHour.t() | nil
  def get(id, repo \\ Read) do
    from(t in ChildCareHour,
      where: is_nil(t.deleted_at),
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Returns a child care hour by id
  """
  @spec get_by(location_id :: binary(), day_of_week :: String.t(), repo :: Ecto.Repo.t()) ::
          ChildCareHour.t() | nil
  def get_by(location_id, day_of_week, repo \\ Read) do
    from(
      t in ChildCareHour,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id,
      where: t.day_of_week == ^day_of_week
    )
    |> repo.all()
    |> List.last()
  end

  @doc """
  Return a list of active child care hours for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [ChildCareHour.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in ChildCareHour,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> repo.all()
  end

  @doc """
  Creates a new child care hour
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ChildCareHour.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ChildCareHour{}
    |> ChildCareHour.update_changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing child care hour
  """
  @spec update(child_care_hour :: ChildCareHour.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ChildCareHour.t()} | {:error, Ecto.Changeset.t()}
  def update(%ChildCareHour{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> ChildCareHour.update_changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a child care hour. This is a logical delete
  """
  @spec delete(child_care_hour :: ChildCareHour.t(), repo :: Ecto.Repo.t()) ::
          {:ok, ChildCareHour.t()} | {:error, :no_record_found}
  def delete(%ChildCareHour{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %ChildCareHour{} = child_care_hour ->
        update(child_care_hour, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
