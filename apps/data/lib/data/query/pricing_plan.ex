defmodule Data.Query.PricingPlan do
  @moduledoc """
  Module for the Pricing Plan queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.PricingPlan
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a pricing plan by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: WifiNetwork.t() | nil
  def get(id, repo \\ Read) do
    from(t in PricingPlan,
      where: is_nil(t.deleted_at),
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of active pricing plan for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [PricingPlan.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in PricingPlan,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> repo.all()
  end

  @doc """
  Returns a matching daily price pass as a map
  """
  @spec active_daily_pass(location_id :: binary(), repo :: Ecto.Repo.t()) :: map()
  def active_daily_pass(location_id, repo \\ Read) do
    from(p in PricingPlan,
      where: is_nil(p.deleted_at),
      where: p.location_id == ^location_id,
      where: p.has_daily == true,
      limit: 1,
      select: %{pass_price: p.daily}
    )
    |> repo.one()
  end

  @doc """
  Returns a matching weekly price pass as a map
  """
  @spec active_weekly_pass(location_id :: binary(), repo :: Ecto.Repo.t()) :: map()
  def active_weekly_pass(location_id, repo \\ Read) do
    from(p in PricingPlan,
      where: is_nil(p.deleted_at),
      where: p.location_id == ^location_id,
      where: p.has_weekly == true,
      limit: 1,
      select: %{pass_price: p.weekly}
    )
    |> repo.one()
  end

  @doc """
  Returns a matching monthly price pass as a map
  """
  @spec active_monthly_pass(location_id :: binary(), repo :: Ecto.Repo.t()) :: map()
  def active_monthly_pass(location_id, repo \\ Read) do
    from(p in PricingPlan,
      where: is_nil(p.deleted_at),
      where: p.location_id == ^location_id,
      where: p.has_monthly == true,
      limit: 1,
      select: %{pass_price: p.monthly}
    )
    |> repo.one()
  end

  @doc """
  Creates a new pricing plan
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, PricingPlan.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %PricingPlan{}
    |> PricingPlan.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing pricing plan
  """
  @spec update(child_care_hour :: PricingPlan.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, PricingPlan.t()} | {:error, Ecto.Changeset.t()}
  def update(%PricingPlan{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> PricingPlan.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a pricing plan. This is a logical delete
  """
  @spec delete(child_care_hour :: PricingPlan.t(), repo :: Ecto.Repo.t()) ::
          {:ok, PricingPlan.t()} | {:error, :no_record_found}
  def delete(%PricingPlan{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %PricingPlan{} = child_care_hour ->
        update(child_care_hour, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
