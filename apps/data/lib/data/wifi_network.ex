defmodule Data.WifiNetwork do
  alias Data.Commands.WifiNetwork

  @roles ["admin", "team-admin", "location-admin"]

  def get_changeset(),
    do: Data.Schema.WifiNetwork.changeset(%Data.Schema.WifiNetwork{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> WifiNetwork.get()
      |> Data.Schema.WifiNetwork.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: WifiNetwork.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: WifiNetwork.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: WifiNetwork.write(params)

  def update(%{"id" => id} = params) do
    id
    |> WifiNetwork.get()
    |> WifiNetwork.write(params)
  end
end
