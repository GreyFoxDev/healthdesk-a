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
  defdelegate get_by_phone(phone_number), to: Query
  defdelegate upsert(params), to: Query

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

  def count_all_new_member(to, from)do
    Query.count_all_new_member(to, from)
  end

  def count_new_member_by(to, from, loc_ids)do
    Query.count_all_new_member_by(to, from, loc_ids)
  end

  def count_active_user()do
    Query.count_active_users()
  end

  def count_active_user_by(loc_ids)do
    Query.count_active_users_by(loc_ids)
  end

  def update(id, params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
