defmodule Data.Query.Intents do
  @moduledoc """
  Module for the intent queries
  """
  import Ecto.Query, only: [from: 2]
  alias Data.Schema.Intent
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a intent by id
  """
  @spec get(intent :: String.t(), repo :: Ecto.Repo.t()) :: Intent.t() | nil
  def get(intent, repo \\ Read) do
    from(t in Intent,
      where: t.intent == ^intent,
      preload: [:location]
    )
    |> repo.one()
  end

  @doc """
  Return a list of intents for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [Intent.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in Intent,
      where: t.location_id == ^location_id,
      order_by: t.inserted_at,
      preload: [:location]
    )
    |> repo.all()
  end

  @doc """
  Return a intent for a location and name
  """
  @spec get_by_name_and_location_id(
          intent :: String.t(),
          location_id :: binary(),
          repo :: Ecto.Repo.t()
        ) :: [Intent.t()]
  def get_by_name_and_location_id(intent, location_id, repo \\ Read) do
    from(t in Intent,
      where: t.location_id == ^location_id,
      where: t.intent == ^intent,
      order_by: t.inserted_at,
      preload: [:location]
    )
    |> repo.one()
  end

  @doc """
  Creates a new intent
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Intent.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Intent{}
    |> Intent.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  rescue
    _ -> {:error, []}
  end

  @doc """
  Updates an existing intent
  """
  @spec update(intent :: Intent.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Intent.t()} | {:error, Ecto.Changeset.t()}
  def update(%Intent{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Intent.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a intent. This is a logical delete
  """
  @spec delete(intent :: Intent.t(), repo :: Ecto.Repo.t()) ::
          {:ok, Intent.t()} | {:error, :no_record_found}
  def delete(%Intent{} = intent, repo \\ Write) do
    intent
    |> case do
      %Intent{} = intent ->
        repo.delete(intent)

      nil ->
        {:error, :no_record_found}
    end
  end
end
