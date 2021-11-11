defmodule Data.ConversationMessages do
  @moduledoc """
  This is the Conversation Message API for the data layer
  """
  alias Data.Query.ConversationMessage, as: Query
  alias Data.Schema.ConversationMessage, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate create(params), to: Query
  defdelegate get_by_conversation_id(conversation_id), to: Query
  defdelegate count_by_location_id(location_id, to, from), to: Query
  defdelegate count_by_team_id(team_id, to, from), to: Query
  defdelegate mark_read(msg), to: Query
  defdelegate count_incoming_messages_per_day_by_location_ids(location_ids, channel_type, to, from), to: Query
  defdelegate count_outgoing_messages_per_day_by_location_ids(location_ids, channel_type, to, from), to: Query
  defdelegate count_incoming_messages_per_day(channel_type, to, from), to: Query
  defdelegate count_outgoing_messages_per_day(channel_type, to, from), to: Query

  def get_changeset(),
    do: Schema.changeset(%Schema{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, conversation_id) when role in @roles,
    do: Query.get_by_conversation_id(conversation_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}
end
