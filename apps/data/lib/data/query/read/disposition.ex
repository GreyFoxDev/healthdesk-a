defmodule Data.Query.ReadOnly.Disposition do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Disposition
  alias Data.ReadOnly.Repo

  def all do
    from(t in Disposition,
      where: is_nil(t.deleted_at)
    )
    |> Repo.all()
  end

  def all(team_id) do
    from(t in Disposition,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Disposition, id)

end
