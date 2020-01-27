defmodule Data.Query.HolidayHour do
  @moduledoc """
  Module for the Holiday Hour queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.HolidayHour
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @doc """
  Returns a holiday hour by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: HolidayHour.t() | nil
  def get(id, repo \\ Read) do
    from(t in HolidayHour,
      where: is_nil(t.deleted_at),
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of active holiday hours for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [HolidayHour.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in HolidayHour,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> repo.all()
  end

  @doc """
  Creates a new holiday hour
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, HolidayHour.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %HolidayHour{}
    |> HolidayHour.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing holiday hour
  """
  @spec update(child_care_hour :: HolidayHour.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, HolidayHour.t()} | {:error, Ecto.Changeset.t()}
  def update(%HolidayHour{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> HolidayHour.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a holiday hour. This is a logical delete
  """
  @spec delete(child_care_hour :: HolidayHour.t(), repo :: Ecto.Repo.t()) ::
          {:ok, HolidayHour.t()} | {:error, :no_record_found}
  def delete(%HolidayHour{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %HolidayHour{} = child_care_hour ->
        update(child_care_hour, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
