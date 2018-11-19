defmodule Data.User do
  alias Data.Commands.User

  @roles ["admin", "system"]

  def get_changeset(),
    do: Data.Schema.User.changeset(%Data.Schema.User{})

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

  def get_by_phone(phone_number, attempt \\ 1) do
    with %Data.Schema.User{} = user <- User.by_phone_number(phone_number) do
      {:ok, user}
    else
      nil ->
        if attempt == 1 do
          :timer.sleep(100)
          get_by_phone(phone_number, 2)
        else
          {:error, :not_found}
        end
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
