defmodule Data.Conversations do
  alias Data.Commands.Conversations

  @roles ["admin"]

  def get_changeset(),
    do: Data.Schema.Conversation.changeset(%Data.Schema.Conversation{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Conversations.get()
      |> Data.Schema.Conversation.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: Conversations.all(location_id)

  def all(_), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Conversations.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: Data.Query.WriteOnly.Conversation.write(params)

  def update(%{"id" => id} = params) do
    id
    |> Conversations.get()
    |> Conversations.write(params)
  end
end
