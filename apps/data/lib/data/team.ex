defmodule Data.Team do
  @moduledoc """
  This is the Team API for the data layer
  """

  alias Data.Query.Team, as: Query
  alias Data.Schema.Team, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: role} = user) when role in ["team-admin", "location-admin"] do
    Query.all() |> Enum.filter(&(&1.id == user.team_member.team_id))
  end

  def all(%{role: role}) when role in @roles,
    do: Query.all()

  def all(_), do: []

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get_bot_id_by_location_id(id),
    do: Query.get_bot_id_by_location_id(id)

  def get_by_location_id(id),
    do: Query.get_by_location_id(id)

  def get_sub_account_id_by_location_id(id),
    do: Query.get_sub_account_id_by_location_id(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: Query.create(params)

  def update(id, params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
