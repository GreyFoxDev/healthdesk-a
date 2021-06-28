defmodule Data.NormalHours do
  @moduledoc """
  This is the Normal Hours API for the data layer
  """
  alias Data.Query.NormalHour, as: Query
  alias Data.Schema.NormalHour, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]
  defdelegate create(params), to: Query
  defdelegate get_by(location_id, day_of_week), to: Query
  defdelegate get_by_location_id(location_id), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def get_update_changeset(params) do
    Schema.update_changeset(%Schema{}, params)
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

  def delete(%{"id" => _id} = params) do
    Query.delete(params)
  end
end
