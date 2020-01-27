defmodule Data.Member do
  @moduledoc """
  This is the Member API for the data layer
  """
  alias Data.Query.Member, as: Query
  alias Data.Schema.Member, as: Schema

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

  def all(%{role: role}) when role in @roles,
    do: Query.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, team_id) when role in @roles,
    do: Query.get_by_team_id(team_id)

  def get_by_phone_number(%{role: role}, phone_number) when role in @roles do
    Query.get_by_phone(phone_number)
  end

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
