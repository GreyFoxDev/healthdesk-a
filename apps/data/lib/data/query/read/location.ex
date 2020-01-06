defmodule Data.Query.ReadOnly.Location do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Location
  alias Data.ReadOnly.Repo

  def all do
    from(t in Location,
      where: is_nil(t.deleted_at)
    )
    |> Repo.all()
  end

  def all(team_id) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id,
      order_by: t.location_name
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Location, id)

  def get_by_phone(phone_number) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.phone_number == ^phone_number,
      limit: 1,
      preload: [:team]
    )
    |> Repo.one()
  end

  def get_by_api_key(key) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.api_key == ^key,
      limit: 1
    )
    |> Repo.one()
  end

  def get_by_messanger_id(messanger_id) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.messanger_id == ^messanger_id,
      limit: 1
    )
    |> Repo.one()
  end
end
