defmodule Data.Query.ReadOnly.Member do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Member
  alias Data.ReadOnly.Repo

  def all do
    from(t in Member,
      where: is_nil(t.deleted_at)
    )
    |> Repo.all()
  end

  def all(team_id) do
    from(t in Member,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Member, id)

  def get_by_phone(phone_number) do
    from(t in Member,
      where: is_nil(t.deleted_at),
      where: t.phone_number == ^phone_number,
      limit: 1
    )
    |> Repo.all()
    |> case do
      [] ->
        nil

      [member] ->
        member
    end
  end
end
