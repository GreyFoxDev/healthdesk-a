defmodule Data.Notes do
  @moduledoc """
  This is the Conversation API for the data layer
  """
  alias Data.Query.Note, as: Query
  alias Data.Schema.Note, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate create(params), to: Query
  defdelegate get_by_conversation(conversation_id), to: Query

  @doc """
  Get changesets for conversations.
  """
  def get_changeset(),
    do: Data.Schema.Note.changeset(%Data.Schema.Note{})

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
