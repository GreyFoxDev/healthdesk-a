defmodule Data.Query.ReadOnly.MemberChannel do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.MemberChannel
  alias Data.ReadOnly.Repo

  def all do
    Repo.all(MemberChannel)
  end

  def all(member_id) do
    query = from(t in MemberChannel,
      where: t.member_id == ^member_id
    )

    Repo.all(query)
  end

  def get(id),
    do: Repo.get(MemberChannel, id)

  def get_by_channel_id(channel_id) do
    query = from(t in MemberChannel,
      where: t.channel_id == ^channel_id,
      limit: 1,
      preload: [:member]
    )

    query
    |> Repo.all()
    |> case do
         [] ->
           nil

         [member_channel] ->
           member_channel

       end
  end
end
