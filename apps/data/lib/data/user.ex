defmodule Data.User do
  alias Data.Commands.User

  @roles ["admin", "team-admin", "location-admin", "teammate", "system"]

  def get_changeset(),
    do: Data.Schema.User.changeset(%Data.Schema.User{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> User.get()
      |> Data.Schema.User.changeset()

    {:ok, changeset}
  end

  def authorize(phone_number) do
    with %Data.Schema.User{} = user <- User.by_phone_number(phone_number) do
      {:ok, user}
    else
      nil ->
        {:error, :not_found}
    end
  end

  def all(%{role: role}) when role in @roles,
    do: User.all()

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: User.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_phone(phone_number) do
    with %Data.Schema.User{} = user <- User.by_phone_number(phone_number) do
      {:ok, user}
    else
      nil ->
        {:ok, nil}
    end
  end

  def create(params),
    do: User.write(params)

  def update(id, params) do
    id
    |> User.get()
    |> User.write(params)
  end
end
