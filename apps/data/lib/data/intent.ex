defmodule Data.Intent do
  @moduledoc """
  This is the Intent API for the data layer
  """
  alias Data.Query.Intents, as: Query
  alias Data.Schema.Intent, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate get(location_id), to: Query
  defdelegate create(params), to: Query
  defdelegate update(intent, params), to: Query
  defdelegate get_by_location_id(location_id), to: Query
  defdelegate delete(intent), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(intent, %{role: role}) when role in @roles do
    changeset =
      intent
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def get_by(intent, location_id),
    do: Query.get_by_name_and_location_id(intent, location_id)

  def get_by(_), do: {:error, :invalid_permissions}

  def all(%{role: role}, location_id) when role in @roles,
    do: Query.get_by_location_id(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, intent) when role in @roles,
    do: Query.get(intent)

  def get(_, _), do: {:error, :invalid_permissions}
end
