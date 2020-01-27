defmodule Data.Query.ReadOnly.ChildCareHours do
  # @moduledoc false

  # import Ecto.Query, only: [from: 2]

  # alias Data.Schema.ChildCareHour
  # alias Data.ReadOnly.Repo

  # def all,
  #   do: Repo.all(ChildCareHour)

  # def all(location_id) do
  #   from(t in ChildCareHour,
  #     where: is_nil(t.deleted_at),
  #     where: t.location_id == ^location_id
  #   )
  #   |> Repo.all()
  # end

  # def get(id),
  #   do: Repo.get(ChildCareHour, id)
end
