defmodule Data.NormalHours do
  alias Data.Commands.NormalHours

  @roles ["admin", "team-admin", "location-admin"]

  def get_changeset(),
    do: Data.Schema.NormalHour.changeset(%Data.Schema.NormalHour{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> NormalHours.get()
      |> Data.Schema.NormalHour.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: NormalHours.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: NormalHours.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: NormalHours.write(params)

  def update(%{"id" => id} = params) do
    id
    |> NormalHours.get()
    |> NormalHours.write(params)
  end
end
