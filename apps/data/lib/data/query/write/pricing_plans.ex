defmodule Data.Query.WriteOnly.PricingPlans do
  @moduledoc false

  alias Data.Schema.PricingPlan
  alias Data.ReadOnly.Repo

  def write(params) do
    %PricingPlan{}
    |> PricingPlan.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> PricingPlan.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
