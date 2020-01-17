defmodule Data.Disposition do
  alias Data.Commands.Disposition

  @roles [
    "admin",
    "system",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  defdelegate count(disposition_id), to: Data.Query.ReadOnly.Disposition
  defdelegate count_all(), to: Data.Query.ReadOnly.Disposition
  defdelegate count_by_team_id(team_id), to: Data.Query.ReadOnly.Disposition

  def get_changeset(),
    do: Data.Schema.Disposition.changeset(%Data.Schema.Disposition{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Disposition.get()
      |> Data.Schema.Disposition.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: Disposition.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Disposition.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, id) when role in @roles,
    do: Disposition.all(id)

  def create(params),
    do: Disposition.write(params)

  def update(id, params) do
    id
    |> Disposition.get()
    |> Disposition.write(params)
  end
end
