defmodule Data.Query.ReadOnly.OptIn do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.OptIn
  alias Data.ReadOnly.Repo

  def get(id),
    do: Repo.get(OptIn, id)

  def get_by_phone(phone_number),
    do: Repo.get_by(OptIn, phone_number: phone_number)
end
