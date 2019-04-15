defmodule Data.Member do
  alias Data.Commands.Member

  @roles [
    "admin",
    "system",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  def get_changeset(),
    do: Data.Schema.Member.changeset(%Data.Schema.Member{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Member.get()
      |> Data.Schema.Member.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: Member.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Member.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_team_id(%{role: role}, id) when role in @roles,
    do: Member.all(id)

  def get_by_phone_number(%{role: role}, phone_number) when role in @roles,
    do: Member.by_phone_number(phone_number)

  def create(params),
    do: Member.write(params)

  def update(id, params) do
    id
    |> Member.get()
    |> Member.write(params)
  end
end
