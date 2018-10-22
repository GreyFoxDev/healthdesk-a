defmodule Data.ChildCareHours do
  alias Data.Commands.ChildCareHours

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.ChildCareHour.changeset(%Data.Schema.ChildCareHour{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> ChildCareHours.get()
      |> Data.Schema.ChildCareHour.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: ChildCareHours.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: ChildCareHours.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: ChildCareHours.write(params)

  def update(%{"id" => id} = params) do
    id
    |> ChildCareHours.get()
    |> ChildCareHours.write(params)
  end
end
