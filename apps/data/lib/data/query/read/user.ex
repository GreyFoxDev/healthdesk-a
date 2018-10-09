defmodule Data.Query.ReadOnly.User do
  @moduledoc false

  alias Data.Schema.User
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(User)

  def get(id),
    do: Repo.get(User, id)

  def get_by_phone(phone_number),
    do: Repo.get_by(User, phone_number: phone_number)
end
