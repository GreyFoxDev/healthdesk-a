defmodule Data.Query.ReadOnly.PricingPlans do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.PricingPlan
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(PricingPlan)

  def all(location_id) do
    location_id
    |> query()
    |> Repo.all()
  end

  def active_daily_pass(location_id) do
    query = query(location_id)

    from(p in query,
      where: p.has_daily == true,
      select: %{pass_price: p.daily}
    )
    |> get_results()
  end

  def active_weekly_pass(location_id) do
    query = query(location_id)

    from(p in query,
      where: p.has_weekly == true,
      select: %{pass_price: p.weekly}
    )
    |> get_results()
  end

  def active_monthly_pass(location_id) do
    query = query(location_id)

    from(p in query,
      where: p.has_monthly == true,
      select: %{pass_price: p.monthly}
    )
    |> get_results()
  end

  def get(id),
    do: Repo.get(PricingPlan, id)

  defp query(location_id) do
    from(t in PricingPlan,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
  end

  defp get_results(query) do
    with [%{} = pass] <- Repo.all(query) do
      {:ok, pass}
    else
      [] ->
        {:ok, nil}

      results ->
        IO.inspect(results)
        {:error, "Query returned more than one matching record for pricing plan"}
    end
  end
end
