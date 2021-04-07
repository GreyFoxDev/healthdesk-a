defmodule Data.Query.ClassSchedule do
  @moduledoc """
  Module for the Class Schedule queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.ClassSchedule
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a child care hour record by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: ClassSchedule.t() | nil
  def get(id, repo \\ Read) do
    from(t in ClassSchedule,
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of class schedules for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [ClassSchedule.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in ClassSchedule,
      where: t.location_id == ^location_id,
      order_by: [:date, :start_time]
    )
    |> repo.all()
  end

  @doc """
  Creates a new class schedule
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ClassSchedule.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ClassSchedule{}
    |> ClassSchedule.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a class schedule. This is a physical delete
  """
  @spec delete(class_schedule :: ClassSchedule.t(), repo :: Ecto.Repo.t()) ::
          {:ok, ClassSchedule.t()} | {:error, :no_record_found}
  def delete(%ClassSchedule{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %ClassSchedule{} = class_schedule ->
        repo.delete(class_schedule)

      nil ->
        {:error, :no_record_found}
    end
  end
end
