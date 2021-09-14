defmodule Data.User do
  @moduledoc """
  This is the User API for the data layer
  """
  alias Data.Query.User, as: Query
  alias Data.Schema.User, as: Schema

  @roles [
    "admin",
    "team-admin",
    "location-admin",
    "teammate",
    "system"
  ]

  defdelegate create(params), to: Query
  defdelegate get_by_phone(phone_number), to: Query
  defdelegate get_phone_by_id(id), to: Query
  defdelegate get_admin_emails(), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def update(id, params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
