defmodule Data.TeamMember do
  alias Data.Commands.TeamMember

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.TeamMember.changeset(%Data.Schema.TeamMember{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> TeamMember.get()
      |> Data.Schema.TeamMember.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: TeamMember.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: TeamMember.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, id) when role in @roles,
    do: TeamMember.all(id)

  def create(params),
    do: TeamMember.write(params)

  def update(id, params) do
    id
    |> TeamMember.get()
    |> TeamMember.write(params)
  end
end
