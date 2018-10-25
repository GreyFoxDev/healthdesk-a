defmodule Data.Team do
  alias Data.Commands.Team

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.Team.changeset(%Data.Schema.Team{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Team.get()
      |> Data.Schema.Team.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: Team.all()

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Team.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: Team.write(params)

  def update(id, params) do
    id
    |> Team.get()
    |> Team.write(params)
  end
end
