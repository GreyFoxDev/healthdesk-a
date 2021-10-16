defmodule Data.Query.IntentUsage do
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{IntentUsage, ConversationMessage, Conversation, Location, Team}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Ecto.Adapters.SQL

  def create(params, repo \\ Write)do
    %IntentUsage{}
    |> IntentUsage.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true}=changeset ->
      repo.insert(changeset)

      changeset ->
        {:error, changeset}
       end
  end

  def count_intent_by(to, from,repo \\ Read)do

    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)
    query = from(t in IntentUsage,
      join: cm in ConversationMessage, on: cm.id == t.message_id,
      join: c in Conversation, on: cm.conversation_id == c.id,
      join: l in Location, on: c.location_id == l.id,
      join: te in Team, on: l.team_id == te.id,
      where: is_nil(l.deleted_at) and is_nil(te.deleted_at),
    )

    query = Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to),
           do: query,
           else: from(t in query, where: t.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from),
           do: query,
           else: from(t in query, where: t.inserted_at >= ^from)

      _, query ->
        query
    end)

    from(t in query,
#       group_by: t.intent,
        select: %{count: count(t.id), intent: t.intent},
        group_by: t.intent,
        order_by: [desc: count(t.id)]
       )
       |> repo.all()
  end

  def count_by_team_id(team_id, to, from, repo \\ Read)do

    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query = from(t in IntentUsage,
      join: m in ConversationMessage, on:  m.id == t.message_id,
      join: c in Conversation, on: c.id == m.conversation_id,
      join: l in Location, on: l.id == c.location_id,
      join: te in Team, on: te.id == l.team_id,
      where: te.id == ^team_id
    )

    query = Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to),
           do: query,
           else: from(t in query, where: t.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from),
           do: query,
           else: from(t in query, where: t.inserted_at >= ^from)

      _, query ->
        query
    end)

    query = from(t in query,
        select: %{count: count(t.id), intent: t.intent},
        group_by: t.intent,
        order_by: [desc: count(t.id)]
#        group_by: t.intent
        )
        |> repo.all()
  end

  def count_by_location_ids(location_ids, to, from, repo \\ Read)do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query = from(t in IntentUsage,
      join: m in ConversationMessage, on:  m.id == t.message_id,
      join: c in Conversation, on: c.id == m.conversation_id,
      join: l in Location, on: l.id == c.location_id,
      where: l.id in ^location_ids
    )

    query = Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to),
           do: query,
           else: from(t in query, where: t.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from),
           do: query,
           else: from(t in query, where: t.inserted_at >= ^from)

      _, query ->
        query
    end)

    query = from(t in query,
              select: %{count: count(t.id), intent: t.intent},
              group_by: t.intent,
              order_by: [desc: count(t.id)]
              #        group_by: t.intent
            )
            |> repo.all()
  end

  def count_all(repo \\ Read)do
    from(t in IntentUsage,
    join: cm in ConversationMessage, on: cm.id == t.message_id,
    join: c in Conversation, on: cm.conversation_id == c.id,
    join: l in Location, on: c.location_id == l.id,
    join: te in Team, on: l.team_id == te.id,
    where: is_nil(l.deleted_at) and is_nil(te.deleted_at),
    select: %{count: count(t.id),intent: t.intent},
    group_by: t.intent,
    order_by: [desc: count(t.id)]
    )
    |> repo.all()
  end

end