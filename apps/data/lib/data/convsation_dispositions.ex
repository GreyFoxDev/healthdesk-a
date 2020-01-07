defmodule Data.ConversationDisposition do
  alias Data.Commands.ConversationDisposition

  @roles [
    "admin",
    "system",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  def get_changeset(),
    do: Data.Schema.ConversationDisposition.changeset(%Data.Schema.ConversationDisposition{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> ConversationDisposition.get()
      |> Data.Schema.ConversationDisposition.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: ConversationDisposition.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: ConversationDisposition.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def create(params),
    do: ConversationDisposition.write(params)
end
