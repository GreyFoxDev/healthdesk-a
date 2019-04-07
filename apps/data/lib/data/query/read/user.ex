defmodule Data.Query.ReadOnly.User do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.User
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(User)

  def get(id) do
    from(u in User,
      left_join: t in assoc(u, :team_member),
      where: is_nil(u.deleted_at),
      where: u.id == ^id,
      preload: [team_member: {t, [team_member_locations: [location: :conversations]]}]
    )
    |> Repo.one()
  end

  def get_by_phone(phone_number) do
    from(u in User,
      left_join: t in assoc(u, :team_member),
      where: is_nil(u.deleted_at),
      where: u.phone_number == ^phone_number,
      preload: [team_member: {t, team_member_locations: :location}]
    )
    |> Repo.one()
  end
end
