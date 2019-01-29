defmodule Data.OptIn do
  alias Data.Commands.OptIn

  @roles ["system"]

  def get_changeset(),
    do: Data.Schema.OptIn.changeset(%Data.Schema.OptIn{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> OptIn.get()
      |> Data.Schema.OptIn.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: OptIn.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: OptIn.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_phone_number(%{role: role}, phone_number) when role in @roles,
    do: OptIn.by_phone_number(phone_number)

  def create(%{role: role}, params) when role in @roles,
    do: OptIn.write(params)

  def update(%{role: role}, id, params) when role in @roles do
    id
    |> OptIn.get()
    |> OptIn.write(params)
  end
end
