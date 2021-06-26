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
  defdelegate count_by_location_id(location_id), to: Query
  defdelegate average_per_day(), to: Query
  defdelegate average_per_day_for_team(team_id), to: Query
  defdelegate average_per_day_for_location(location_id), to: Query

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

  def count_by(%{"location_id" => location_id, "to" => to, "from" => from}),
      do: Query.get_by(location_id, convert_string_to_date(to), convert_string_to_date(from))

  def count_by(%{"team_id" => team_id, "to" => to, "from" => from}),
      do: Query.count_by_team(team_id, convert_string_to_date(to), convert_string_to_date(from))

  def count_all_by(%{"to" => to, "from" => from}),
      do: Query.count_all_by(convert_string_to_date(to), convert_string_to_date(from))

  def get_by_team_id(%{role: role}, team_id) when role in @roles,
    do: Query.get_by_team_id(team_id)

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end

  defp convert_string_to_date(date) do
    case Date.from_iso8601(date) do
      {:ok, date} -> Timex.to_datetime(date) |> DateTime.to_naive()
      _-> nil
    end
  end
end