defmodule Data.SavedReply do
  @moduledoc """
  This is the Conversation Message API for the data layer
  """
  alias Data.Query.SavedReply, as: Query
  alias Data.Schema.SavedReply, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate get(location_id), to: Query
  defdelegate create(params), to: Query
  defdelegate update(saved_reply, params), to: Query
  defdelegate get_by_location_id(location_id), to: Query
  defdelegate delete(saved_reply), to: Query

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

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}
end
