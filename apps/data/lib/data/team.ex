defmodule Data.Team do

  alias Data.Commands

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.Team.changeset(%Data.Schema.Team{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Commands.SelectTeam.run()
      |> Data.Schema.Team.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: Commands.ListTeams.run()

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Commands.SelectTeam.run(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: Commands.WriteTeam.run(params)

  def update(id, params) do
    id
    |> Commands.SelectTeam.run()
    |> Commands.WriteTeam.run(params)
  end
end
