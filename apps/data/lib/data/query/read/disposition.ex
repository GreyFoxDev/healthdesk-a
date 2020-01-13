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

  def count(disposition_id) do
    (from cd in Data.Schema.ConversationDisposition,
      join: d in Disposition, on: cd.disposition_id == d.id,
      where: d.id == ^disposition_id,
      select: count(cd.id)
    ) |> Repo.one
  end

end
