defmodule Data.Location do
  @moduledoc """
  This is the Location API for the data layer
  """
  alias Data.Query.Location, as: Query
  alias Data.Schema.Location, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate get_by_phone(phone_number), to: Query
  defdelegate get_by_api_key(api_key), to: Query
  defdelegate get_by_page_id(page_id), to: Query
  defdelegate get_by_messenger_id(messenger_id), to: Query
  defdelegate create(params), to: Query
  defdelegate get(location_id), to: Query
  defdelegate get_automation_limit(location_id), to: Query
  defdelegate all(), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: "location-admin"} = user) do
    Query.all() |> Enum.filter(&(&1.id == user.team_member.location_id))
  end

  def all(%{role: role}) when role in @roles,
    do: Query.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get_locations_by_ids(%{role: role}, id) when role in @roles,
    do: Query.get_locations_by_ids(id)

  def get(_, _), do: {:error, :invalid_permissions}
  def get(id), do: Query.get(id)

  def get_by_team_id(%{role: role}, team_id) when role in @roles,
    do: Query.get_by_team_id(team_id)

  def get_location_ids_by_team_id(%{role: role}, team_id) when role in @roles,
    do: Query.get_location_ids_by_team_id(team_id)

  def update(id, params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
