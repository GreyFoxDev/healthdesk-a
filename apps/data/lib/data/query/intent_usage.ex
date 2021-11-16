defmodule Data.Query.IntentUsage do
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{IntentUsage, ConversationMessage, Conversation, Location, Team}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Ecto.Adapters.SQL

  @new_leads_intents ["salesQuestion",
    "getTour",
    "getTrialPass",
    "getGuestPass",
    "getMonthPass",
    "getDayPass",
    "getWeekPass"]

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
      where: is_nil(l.deleted_at) and is_nil(te.deleted_at)
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
             repo.all(query)
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

  def get_intent_after_call(disposition,to,from, loc_ids, repo \\ Read)do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)
    query = if List.first(loc_ids) do
      from(t in IntentUsage,
        join: cm in Data.Schema.ConversationMessage, on: t.message_id == cm.id,
        join: c in Data.Schema.Conversation, on: cm.conversation_id == c.id,
        join: cc in Data.Schema.ConversationCall, on: c.original_number == cc.original_number and c.location_id == cc.location_id,
        join: cd in Data.Schema.ConversationDisposition, on: cd.conversation_call_id == cc.id,
        join: d in Data.Schema.Disposition, on: d.id == cd.disposition_id,
        where: d.disposition_name in ^disposition,
        where: cc.location_id in ^loc_ids,
        where: cm.inserted_at > cd.inserted_at,
        distinct: t.id
        #          group_by: [ t.id],
      )
    else
      from(t in IntentUsage,
        join: cm in Data.Schema.ConversationMessage, on: t.message_id == cm.id,
        join: c in Data.Schema.Conversation, on: cm.conversation_id == c.id,
        join: cc in Data.Schema.ConversationCall, on: c.original_number == cc.original_number and c.location_id == cc.location_id,
        join: cd in Data.Schema.ConversationDisposition, on: cd.conversation_call_id == cc.id,
        join: d in Data.Schema.Disposition, on: d.id == cd.disposition_id,
        where: d.disposition_name in ^disposition,
        where: cm.inserted_at > cd.inserted_at,
        distinct: t.id
        #          group_by: [ t.id],
      )
    end
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([t, ...] in query, where: t.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([t, ...] in query, where: t.inserted_at >= ^from)

        _, query ->
          query
      end)
#    query = from([t,cm,c,cc,cd, ...] in query,
#      select: {cm.inserted_at, cd.conversation_call_id})
      query = from([t, ...] in query,
      select: [id: t.id, name: t.intent]
      )
    repo.all(query)

  end

  def get_new_leads(disposition,to,from, loc_ids ,repo \\ Read)do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)
    query = if List.first(loc_ids)do
      from(t in IntentUsage,
        join: cm in Data.Schema.ConversationMessage, on: t.message_id == cm.id,
        join: c in Data.Schema.Conversation, on: cm.conversation_id == c.id,
        join: cc in Data.Schema.ConversationCall, on: c.original_number == cc.original_number and c.location_id == cc.location_id,
        join: cd in Data.Schema.ConversationDisposition, on: cd.conversation_call_id == cc.id,
        join: d in Data.Schema.Disposition, on: d.id == cd.disposition_id,
        where: d.disposition_name in ^disposition,
        where: cc.location_id in ^loc_ids,
        where: cm.inserted_at > cd.inserted_at and t.intent in @new_leads_intents,
        distinct: t.id
        #    group_by: t.id,
      )
    else
      from(t in IntentUsage,
        join: cm in Data.Schema.ConversationMessage, on: t.message_id == cm.id,
        join: c in Data.Schema.Conversation, on: cm.conversation_id == c.id,
        join: cc in Data.Schema.ConversationCall, on: c.original_number == cc.original_number and c.location_id == cc.location_id,
        join: cd in Data.Schema.ConversationDisposition, on: cd.conversation_call_id == cc.id,
        join: d in Data.Schema.Disposition, on: d.id == cd.disposition_id,
        where: d.disposition_name in ^disposition,
        where: cm.inserted_at > cd.inserted_at and t.intent in @new_leads_intents,
        distinct: t.id
        #    group_by: t.id,
      )
    end
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([t, ...] in query, where: t.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([t, ...] in query, where: t.inserted_at >= ^from)

        _, query ->
          query
      end)
    query = from([t, ...] in query,
      select: t.id)
    repo.all(query) |> Enum.count()
  end
end