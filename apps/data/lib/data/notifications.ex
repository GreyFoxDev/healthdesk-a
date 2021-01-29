defmodule Data.Notifications do
  @moduledoc """
  This is the Conversation API for the data layer
  """
  alias Data.Query.Notification, as: Query
  alias Data.Schema.Notification, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate create(params), to: Query
  defdelegate get_by_user(user_id), to: Query

  @doc """
  Get changesets for conversations.
  """
  def get_changeset(),
    do: Data.Schema.Notification.changeset(%Data.Schema.Notification{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end
end
