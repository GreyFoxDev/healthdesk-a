defmodule Data.Query.ReadOnly.Conversation do
  # @moduledoc false

  # import Ecto.Query, only: [from: 2]

  # alias Data.Schema.{Conversation, Member}
  # alias Data.ReadOnly.Repo

  # def all,
  #   do: Repo.all(Conversation)

  # def all(location_id) do
  #   from(c in Conversation,
  #     join: m in assoc(c, :conversation_messages),
  #     left_join: t in assoc(c, :team_member),
  #     left_join: u in assoc(t, :user),
  #     left_join: member in Member,
  #     on: c.original_number == member.phone_number,
  #     where: c.location_id == ^location_id,
  #     # most recent first
  #     order_by: [desc: m.sent_at],
  #     preload: [conversation_messages: m, team_member: {t, user: u}],
  #     select: %{c | member: member}
  #   )
  #   |> Repo.all()
  # end

  # def get(id) do
  #   from(c in Conversation,
  #     join: m in assoc(c, :conversation_messages),
  #     left_join: t in assoc(c, :team_member),
  #     left_join: u in assoc(t, :user),
  #     left_join: member in Member,
  #     on: c.original_number == member.phone_number,
  #     where: c.id == ^id,
  #     order_by: m.sent_at,
  #     preload: [:location, conversation_messages: m, team_member: {t, user: u}],
  #     select: %{c | member: member}
  #   )
  #   |> Repo.all()
  #   |> case do
  #     [] ->
  #       nil

  #     [conversation] ->
  #       conversation

  #     _ ->
  #       :error
  #   end
  # end

  # def get_by_phone(phone_number, location_id) do
  #   from(c in Conversation,
  #     where: c.original_number == ^phone_number,
  #     where: c.location_id == ^location_id
  #   )
  #   |> Repo.one()
  # end
end
