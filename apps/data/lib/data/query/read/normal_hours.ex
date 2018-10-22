defmodule Data.Query.ReadOnly.NormalHours do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.NormalHour
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(NormalHour)

  def all(location_id) do
    from(t in NormalHour,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(NormalHour, id)
end
