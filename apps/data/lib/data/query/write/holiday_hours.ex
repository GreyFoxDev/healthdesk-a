defmodule Data.Query.WriteOnly.HolidayHours do
  @moduledoc false

  alias Data.Schema.HolidayHour
  alias Data.ReadOnly.Repo

  def write(params) do
    %HolidayHour{}
    |> HolidayHour.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> HolidayHour.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
