defmodule Data.Query.ReadOnly.Conversation do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Conversation
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(Conversation)

  def all(location_id) do
    from(c in Conversation,
      join: m in assoc(c, :conversation_messages),
      left_join: t in assoc(c, :team_member),
      left_join: u in assoc(t, :user),
      where: c.location_id == ^location_id,
      order_by: m.sent_at,
      preload: [conversation_messages: m, team_member: {t, user: u}]
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(Conversation, id)

  def get_by_phone(phone_number) do
    Repo.get_by(Conversation, [original_number: phone_number, status: "open"] )
  end
end
