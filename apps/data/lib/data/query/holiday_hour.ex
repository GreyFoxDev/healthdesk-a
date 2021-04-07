defmodule Data.Query.HolidayHour do
  @moduledoc """
  Module for the Holiday Hour queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.HolidayHour
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

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
  Returns a holiday hour by id
  """
  @spec get_by(location_id :: binary(), holiday_name :: String.t(), repo :: Ecto.Repo.t()) ::
          HolidayHour.t() | nil
  def get_by(location_id, holiday_name, repo \\ Read) do
    from(t in HolidayHour,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id,
      where: t.holiday_name == ^holiday_name
    )
    |> repo.all()
    |> List.last()
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
    |> HolidayHour.update_changeset(params)
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
  @spec update(holiday_hour :: HolidayHour.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, HolidayHour.t()} | {:error, Ecto.Changeset.t()}
  def update(%HolidayHour{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> HolidayHour.update_changeset(params)
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
  @spec delete(holiday_hour :: HolidayHour.t(), repo :: Ecto.Repo.t()) ::
          {:ok, HolidayHour.t()} | {:error, :no_record_found}
  def delete(%HolidayHour{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %HolidayHour{} = holiday_hour ->
        update(holiday_hour, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
