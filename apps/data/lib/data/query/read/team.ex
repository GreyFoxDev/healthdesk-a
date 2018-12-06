defmodule Data.Query.ReadOnly.Team do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Team
  alias Data.ReadOnly.Repo

  def all do
    from(t in Team,
      where: is_nil(t.deleted_at),
      preload: [locations: :conversations]
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Team, id)
end
