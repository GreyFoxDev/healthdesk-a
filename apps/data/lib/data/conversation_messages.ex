defmodule Data.ConversationMessages do
  alias Data.Commands.ConversationMessages

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.ConversationMessage.changeset(%Data.Schema.ConversationMessage{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> ConversationMessages.get()
      |> Data.Schema.ConversationMessage.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: ConversationMessages.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: ConversationMessages.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: ConversationMessages.write(params)

  def update(%{"id" => id} = params) do
    id
    |> ConversationMessages.get()
    |> ConversationMessages.write(params)
  end
end
