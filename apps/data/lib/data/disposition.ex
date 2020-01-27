defmodule Data.Disposition do
  @moduledoc """
  This is the Child Care Hours API for the data layer
  """
  alias Data.Query.Disposition, as: Query
  alias Data.Schema.Disposition, as: Schema

  @roles [
    "admin",
    "system",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate create(params), to: Query
  defdelegate count(disposition_id), to: Query
  defdelegate count_all(), to: Query
  defdelegate count_by_team_id(team_id), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: Query.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, team_id) when role in @roles,
    do: Query.get_by_team_id(team_id)

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
