defmodule Data.MemberChannel do
  alias Data.Commands.MemberChannel

  @roles [
    "admin",
    "system",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  def get_changeset(),
    do: Data.Schema.MemberChannel.changeset(%Data.Schema.MemberChannel{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> MemberChannel.get()
      |> Data.Schema.MemberChannel.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}) when role in @roles,
    do: MemberChannel.all()

  def all(_),
    do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: MemberChannel.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get_by_channel_id(%{role: role}, channel_id) when role in @roles do
    {:ok, member_channel} = MemberChannel.get_by_channel_id(channel_id)
    member_channel
  end

  def create(params),
    do: MemberChannel.write(params)

  def update(id, params) do
    id
    |> MemberChannel.get()
    |> MemberChannel.write(params)
  end
end
