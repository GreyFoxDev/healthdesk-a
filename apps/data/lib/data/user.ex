defmodule Data.User do

  alias Data.Commands

  @roles ["admin", "system"]

  def get_changeset(),
    do: Data.Schema.User.changeset(%Data.Schema.User{})

  def authorize(phone_number) do
    with %Data.Schema.User{} = user <- Commands.SelectUserByPhoneNumber.run(phone_number) do
      {:ok, user}
    else
      nil ->
        {:error, :not_found}
    end
  end

  def all(%{role: role}) when role in @roles,
    do: Commands.ListUsers.run()

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Commands.SelectUser.run(id)

  def get(_, _), do: {:error, :invalid_permissions}
end
