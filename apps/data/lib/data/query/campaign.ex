defmodule Data.Query.Campaign do
  @moduledoc """
  Module for the Pricing Plan queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Campaign
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a campaign by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Campaign.t() | nil
  def get(id, repo \\ Read) do
    from(t in Campaign,
      where: is_nil(t.deleted_at),
      where: t.id == ^id,
      preload: [:location]
    )
    |> repo.one()
  end

  @doc """
  Return a list of active campaign for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [Campaign.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in Campaign,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id,
      order_by: [desc: :send_at],
      preload: [:location, :campaign_recipients]
    )
    |> repo.all()
  end

  @doc """
  Return a list of active campaign for locations
  """
  @spec get_by_location_ids(location_ids :: binary(), repo :: Ecto.Repo.t()) :: [Campaign.t()]
  def get_by_location_ids(location_ids, repo \\ Read) do
    from(t in Campaign,
      where: is_nil(t.deleted_at),
      where: t.location_id in ^location_ids,
      order_by: [desc: :send_at],
      preload: [:location, :campaign_recipients]
    )
    |> repo.all()
  end

  def active_campaigns(repo \\ Read) do
    from(t in Campaign,
      where: is_nil(t.deleted_at),
      where: t.completed == false,
      where: t.send_at < ^DateTime.utc_now()
    )
    |> repo.all()
  end

  @doc """
  Creates a new campaign
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Campaign.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Campaign{}
    |> Campaign.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing campaign
  """
  @spec update(campaign :: Campaign.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Campaign.t()} | {:error, Ecto.Changeset.t()}
  def update(%Campaign{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Campaign.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a campaign. This is a logical delete
  """
  @spec delete(campaign :: Campaign.t(), repo :: Ecto.Repo.t()) ::
          {:ok, Campaign.t()} | {:error, :no_record_found}
  def delete(%Campaign{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %Campaign{} = campaign ->
        update(campaign, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
