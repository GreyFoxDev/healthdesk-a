defmodule Data.Location do
  alias Data.Commands.Location

  @roles ["admin", "teammate", "location-admin", "team-admin"]

  defdelegate get_by_phone(phone_number), to: Location

  def get_changeset(),
    do: Data.Schema.Location.changeset(%Data.Schema.Location{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Location.get()
      |> Data.Schema.Location.changeset()

    {:ok, changeset}
  end

  def all(%{role: "location-admin"} = user) do
    Location.all() |> Enum.filter(&(&1.id == user.team_member.location_id))
  end

  def all(%{role: role}) when role in @roles,
    do: Location.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Location.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, id) when role in @roles,
    do: Location.all(id)

  def get_by_api_key(key),
    do: Location.get_by_api_key(key)

    def get_by_messanger_id(messanger_id),
      do: Location.get_by_messanger_id(messanger_id)

  def create(params),
    do: Location.write(params)

  def update(id, params) do
    id
    |> Location.get()
    |> Location.write(params)
  end
end
