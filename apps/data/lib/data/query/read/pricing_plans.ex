defmodule Data.Query.ReadOnly.PricingPlans do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.PricingPlan
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(PricingPlan)

  def all(location_id) do
    from(t in PricingPlan,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(PricingPlan, id)
end
