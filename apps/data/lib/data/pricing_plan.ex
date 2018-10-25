defmodule Data.PricingPlan do
  alias Data.Commands.PricingPlan

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.PricingPlan.changeset(%Data.Schema.PricingPlan{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> PricingPlan.get()
      |> Data.Schema.PricingPlan.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: PricingPlan.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: PricingPlan.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: PricingPlan.write(params)

  def update(%{"id" => id} = params) do
    id
    |> PricingPlan.get()
    |> PricingPlan.write(params)
  end
end
