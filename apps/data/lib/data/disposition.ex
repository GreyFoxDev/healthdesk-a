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
  #  defdelegate count_by_location_id(location_id), to: Query
  defdelegate average_per_day(params), to: Query
  defdelegate average_per_day_for_team(params), to: Query
  defdelegate average_per_day_for_location(params), to: Query
  defdelegate average_per_day_for_locations(params), to: Query

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

  def count_by(%{"location_ids" => location_ids, "to" => to, "from" => from})do
    Query.get_by(location_ids, to, from) ++ Query.get_call_related_by(location_ids, to, from)
  end


  #  def count_by(%{"location_id" => location_id, "to" => to, "from" => from}),
  #      do: Query.count_by_location_id(location_id, to, from)

  def count_by(%{"team_id" => team_id, "to" => to, "from" => from}),
      do: Query.count_by_team(team_id, to, from)

  def count_by(%{"team_id" => team_id}),
      do: Query.count_by_team_id(team_id)

  def count_all_by(%{"to" => to, "from" => from}),
      do: Query.count_all_by(to, from)

  def count_all_by(%{}),
      do: Query.count_all()

  def get_by_team_id(%{role: role}, team_id) when role in @roles,
      do: Query.get_by_team_id(team_id)

  def get_by_team_and_name(team_id, name),
      do: Query.get_by_team_and_name(team_id, name)

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end

  def convert_string_to_date(date) do
    case date do
      nil ->
        nil

      _ ->
        case Date.from_iso8601(date) do
          {:ok, date} -> Timex.to_datetime(date) |> DateTime.to_naive()
          _ -> nil
        end
    end
  end
end
