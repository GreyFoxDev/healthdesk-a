defmodule Data.Query.ReadOnly.User do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.User
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(User)

  def get(id),
    do: Repo.get(User, id)

  def get_by_phone(phone_number) do
    from(u in User,
      where: is_nil(u.deleted_at),
      where: u.phone_number == ^phone_number,
      limit: 1
    )
    |> Repo.all()
    |> case do
      [] ->
        nil

      [location] ->
        location
    end
  end
end
