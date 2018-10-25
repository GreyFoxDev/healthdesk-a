defmodule Data.HolidayHours do
  alias Data.Commands.HolidayHours

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.HolidayHour.changeset(%Data.Schema.HolidayHour{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> HolidayHours.get()
      |> Data.Schema.HolidayHour.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: HolidayHours.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: HolidayHours.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: HolidayHours.write(params)

  def update(%{"id" => id} = params) do
    id
    |> HolidayHours.get()
    |> HolidayHours.write(params)
  end
end
