defmodule Data.Query.WifiNetwork do
  @moduledoc """
  Module for the Wifi Network queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.WifiNetwork
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a wifi network by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: WifiNetwork.t() | nil
  def get(id, repo \\ Read) do
    from(t in WifiNetwork,
      where: is_nil(t.deleted_at),
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of active wifi networks for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [WifiNetwork.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in WifiNetwork,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> repo.all()
  end

  @doc """
  Creates a new wifi network
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, WifiNetwork.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %WifiNetwork{}
    |> WifiNetwork.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing wifi network
  """
  @spec update(child_care_hour :: WifiNetwork.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, WifiNetwork.t()} | {:error, Ecto.Changeset.t()}
  def update(%WifiNetwork{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> WifiNetwork.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a wifi network. This is a logical delete
  """
  @spec delete(child_care_hour :: WifiNetwork.t(), repo :: Ecto.Repo.t()) ::
          {:ok, WifiNetwork.t()} | {:error, :no_record_found}
  def delete(%WifiNetwork{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %WifiNetwork{} = child_care_hour ->
        update(child_care_hour, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
