defmodule Data.Appointments do
  @moduledoc """
  This is the Conversation API for the data layer
  """
  alias Data.Query.Appointment, as: Query
  alias Data.Schema.Appointment, as: Schema

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate create(params), to: Query
  defdelegate get_by_conversation(convo_id), to: Query
  defdelegate get(convo_id), to: Query
  defdelegate count_all(to, from), to: Query
  defdelegate count_by_team_id(team_id, to, from), to: Query
  defdelegate count_by_location_id(location_id), to: Query
  defdelegate count_by_location_ids(location_ids, to, from), to: Query

  @doc """
  Get changesets for conversations.
  """
  def get_changeset(),
    do: Data.Schema.Appointment.changeset(%Data.Schema.Appointment{})

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
