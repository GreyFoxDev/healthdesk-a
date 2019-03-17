defmodule Data.Query.ReadOnly.ClassSchedule do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.ClassSchedule
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(ClassSchedule)

  def all(location_id) do
    from(t in ClassSchedule,
      where: t.location_id == ^location_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(ClassSchedule, id)
end
