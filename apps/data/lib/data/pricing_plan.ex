defmodule Data.PricingPlan do
  @moduledoc """
  This is the Pricing Plan API for the data layer
  """
  alias Data.Query.PricingPlan, as: Query
  alias Data.Schema.PricingPlan, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate create(params), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: Query.get_by_location_id(location_id)

  def all(_, _), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end

  def price_plans(type, location_id) when type in [:daily, :weekly, :monthly] do
    case type do
      :daily ->
        Query.active_daily_pass(location_id)

      :weekly ->
        Query.active_weekly_pass(location_id)

      :monthly ->
        Query.active_monthly_pass(location_id)
    end
  end
end
