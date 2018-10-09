defmodule Data.Location do

  alias Data.Commands

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.Location.changeset(%Data.Schema.Location{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Commands.SelectLocation.run()
      |> Data.Schema.Location.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: Commands.ListLocations.run()

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Commands.SelectLocation.run(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, id) when role in @roles,
    do: Commands.SelectLocationByTeamId.run(id)

  def get_by_team_id(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: Commands.WriteLocation.run(params)

  def update(id, params) do
    id
    |> Commands.SelectLocation.run()
    |> Commands.WriteLocation.run(params)
  end
end
