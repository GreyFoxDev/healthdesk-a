defmodule Data.Query.ReadOnly.HolidayHours do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.HolidayHour
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(HolidayHour)

  def all(location_id) do
    from(t in HolidayHour,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(HolidayHour, id)
end
