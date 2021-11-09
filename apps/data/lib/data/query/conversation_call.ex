defmodule Data.Query.ConversationCall do
  @moduledoc """
  Module for the ConversationCall queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{ConversationCall, Disposition, ConversationList, Member, Conversation, ConversationDisposition, ConversationMessage}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a ConversationCall by id
  """
  @spec get(id :: binary(), check :: boolean(), repo :: Ecto.Repo.t()) ::
          ConversationCall.t() | nil
  def get(id, preload_f \\ true, repo \\ Read)

  def get(id, false, repo) do
    from(c in ConversationCall,
      #      left_join: member in Member,
      #      on: c.original_number == member.phone_number,
      where: c.id == ^id,
      preload: [:location, team_member: [:user]],
      select: c
    )
    |> repo.one()
  end

  def get(id, true, repo) do
    from(c in ConversationCall,
      #      join: m in assoc(c, :conversation_messages),
      #      left_join: member in Member,
      #      on: c.original_number == member.phone_number,
      where: c.id == ^id,
      #      order_by: [desc: m.sent_at],
      preload: [:location, team_member: [:user]],
      select: c
    )
    |> repo.one()
  end

  @doc """
  Update ConversationCalls
  """
  @spec update_conversation(repo :: Ecto.Repo.t()) :: [ConversationCall.t()]
  def update_conversation(repo \\ Read) do
    time = DateTime.add(DateTime.utc_now(), -24 * 3600)

    _query =
      from(
        c in ConversationCall,
        where: c.appointment == true and c.updated_at > ^time,
        select: c.appointment
      )
      |> repo.update_all(
           set: [
             appointment: false
           ]
         )
  end

  @doc """
  Return a list of ConversationCalls for a location
  """
  @spec get_by_status(location_id :: [binary()], status :: [binary()], repo :: Ecto.Repo.t()) :: [
                                                                                                   Conversation.t()
                                                                                                 ]
  def get_by_status(location_id, status, search_string, repo \\ Read) when is_list(status) do
    time = DateTime.add(DateTime.utc_now(), -1_296_000, :seconds)
    like = "%#{search_string}%"

    from(c in ConversationCall,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      left_join: location in assoc(c, :location),
      on: c.original_number == member.phone_number,
      where: c.location_id in ^location_id,
      where: c.status in ^status,
      where: m.sent_at >= ^time,
      or_where:
        like(c.original_number, ^like) or like(c.channel_type, ^like) or
        like(location.location_name, ^like) or
        like(member.first_name, ^like) or like(member.phone_number, ^like) or
        like(member.last_name, ^like),
      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user], location: []],
      select: %{c | member: member}
    )
    |> repo.all()
  end

  def get_by_status(location_id, status) when is_list(status) do
    repo = Read
    time = DateTime.add(DateTime.utc_now(), -1_296_000, :seconds)

    q =
      from(c in ConversationCall,
        join: m in assoc(c, :conversation_messages),
        left_join: member in Member,
        on: c.original_number == member.phone_number,
        where: c.location_id in ^location_id,
        where: c.status in ^status,
        where: m.sent_at >= ^time,
        # most recent first
        order_by: [desc: m.sent_at],
        preload: [conversation_messages: m, team_member: [:user], location: []],
        select: %{c | member: member}
      )

    q
    |> repo.all()
  end

  def get_by_status_count(location_id, status, repo \\ Read) when is_list(status) do
    from(c in ConversationCall,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id in ^location_id,
      where: c.status in ^status,
      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user], location: []],
      select: %{c | member: member}
    )
    |> repo.all()
  end

  @doc """
  Return a list of limited conversations for a location
  """

  def get_limited_conversations(location_id, status, offset, limit, user_id, true)
      when is_list(status) do
    from(
      c in ConversationList,
      where: c.status in ^status,
      where: c.location_id in ^location_id,
      where: c.user_id == ^user_id or is_nil(c.user_id),
      offset: ^offset,
      limit: ^limit
    )
    |> Read.all()
  end

  def get_limited_conversations(location_id, status, offset, limit, user_id)
      when is_list(status) do
    from(
      c in ConversationList,
      where: c.status in ^status,
      where: c.location_id in ^location_id,
      where: c.user_id != ^user_id,
      offset: ^offset,
      limit: ^limit
    )
    |> Read.all()
  end

  def get_limited_conversations(location_id, status, offset, limit) when is_list(status) do
    from(
      c in ConversationList,
      where: c.status in ^status,
      where: c.location_id in ^location_id,
      offset: ^offset,
      limit: ^limit
    )
    |> Read.all()
  end

  def get_filtered_conversations(location_id, status, user_id, true, s) when is_list(status) do
    like = "%#{s}%"

    from(
      c in ConversationList,
      where: c.status in ^status,
      where: c.location_id in ^location_id,
      where: c.user_id == ^user_id or is_nil(c.user_id),
      where:
        like(c.original_number, ^like) or like(c.channel_type, ^like) or
        like(c.location_name, ^like) or
        like(c.first_name, ^like) or like(c.last_name, ^like)
    )
    |> Read.all()
  end

  def get_filtered_conversations(location_id, status, user_id, s) when is_list(status) do
    like = "%#{s}%"

    from(
      c in ConversationList,
      where: c.status in ^status,
      where: c.location_id in ^location_id,
      where: c.user_id != ^user_id,
      where:
        like(c.original_number, ^like) or like(c.channel_type, ^like) or
        like(c.location_name, ^like) or
        like(c.first_name, ^like) or like(c.last_name, ^like)
    )
    |> Read.all()
  end

  def get_filtered_conversations(location_id, status, s) when is_list(status) do
    like = "%#{s}%"

    from(
      c in ConversationList,
      where: c.status in ^status,
      where: c.location_id in ^location_id,
      where:
        like(c.original_number, ^like) or like(c.channel_type, ^like) or
        like(c.location_name, ^like) or
        like(c.first_name, ^like) or like(c.last_name, ^like)
    )
    |> Read.all()
  end

  def get_conversations(ids, repo) do
    from(c in ConversationCall,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.id in ^ids,
      order_by: [desc: m.sent_at],
      preload: [:location, conversation_messages: m, team_member: [:user]],
      select: %{c | member: member}
    )
    |> repo.all()
  end

  @spec get_by_location_ids(location_id :: [binary()], repo :: Ecto.Repo.t()) :: [
                                                                                   ConversationCall.t()
                                                                                 ]
  def get_by_location_ids(location_id, repo \\ Read) do
    from(c in ConversationCall,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id in ^location_id,

      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user]],
      select: %{c | member: member}
    )
    |> repo.all()
  end

  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [
                                                                                ConversationCall.t()
                                                                              ]
  def get_by_location_id(location_id, repo \\ Read) do
    from(c in ConversationCall,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id == ^location_id,

      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user]],
      select: %{c | member: member}
    )
    |> repo.all()
  end

  @doc """
  Return a single ConversationCall by a unique phone number and location id
  """
  @spec get_by_phone(phone_number :: String.t(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get_by_phone(phone_number, location_id, repo \\ Read) do
    from(c in ConversationCall,
      where: c.original_number == ^phone_number,
      where: c.location_id == ^location_id
    )
    |> repo.one()
  end

  @doc """
  Creates a new ConversationCall
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationCall.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ConversationCall{}
    |> ConversationCall.changeset(params)
    |> case do
         %Ecto.Changeset{valid?: true} = changeset ->
           repo.insert(changeset)

         changeset ->
           {:error, changeset}
       end
  end

  @doc """
  Updates an existing ConversationCall
  """
  @spec update(conversation :: ConversationCall.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationCall.t()} | {:error, Ecto.Changeset.t()}
  def update(%ConversationCall{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> ConversationCall.changeset(params)
    |> case do
         %Ecto.Changeset{valid?: true} = changeset ->
           repo.update(changeset)

         changeset ->
           {:error, changeset}
       end
  end

  def get_call_time_list(disposition,to,from, loc_ids \\ [] ,repo \\ Read)do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query = if List.first(loc_ids)do
      from(cd in ConversationDisposition,
        join: cc in ConversationCall, on: cc.id == cd.conversation_call_id,
        join: d in Disposition, on: cd .disposition_id == d.id,
        where: d.disposition_name in ^disposition,
        where: not is_nil(cd.conversation_call_id),
        where: cc.location_id in ^loc_ids,
        distinct: cd.id,
      )
    else
      from(cd in ConversationDisposition,
        join: d in Disposition, on: cd .disposition_id == d.id,
        where: d.disposition_name in ^disposition,
        where: not is_nil(cd.conversation_call_id),
        distinct: cd.id,
      )
    end
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([cd, ...] in query, where: cd.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([cd, ...] in query, where: cd.inserted_at >= ^from)

        _, query ->
          query
      end)
    query = from([cd, ...] in query,
      select: {cd.inserted_at, cd.conversation_call_id},
      group_by: [cd.inserted_at, cd.conversation_call_id, cd.id]
    )
    repo.all(query)
  end

  def get_messages(disposition,to,from, loc_ids \\ [], repo \\ Read)do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)
    query = if List.first(loc_ids)do
      from( c in Conversation,
        join: cc in ConversationCall, on: c.original_number == cc.original_number and c.location_id == cc.location_id,
        join: cd in ConversationDisposition, on: cc.id == cd.conversation_call_id,
        join: cm in ConversationMessage,on: cm.conversation_id == c.id,
        where: cm.phone_number == c.original_number,
        where: cc.location_id in ^loc_ids,
        join: d in Disposition, on: d.id == cd.disposition_id,
        where: d.disposition_name in ^disposition,
        distinct: cm.id
      )
    else
      from( c in Conversation,
        join: cc in ConversationCall, on: c.original_number == cc.original_number and c.location_id == cc.location_id,
        join: cd in ConversationDisposition, on: cc.id == cd.conversation_call_id,
        join: cm in ConversationMessage,on: cm.conversation_id == c.id,
        where: cm.phone_number == c.original_number,
        join: d in Disposition, on: d.id == cd.disposition_id,
        where: d.disposition_name in ^disposition,
        distinct: cm.id
      )
    end
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_,cc, _,cm, ...] in query, where: cm.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_,cc, _,cm, ...] in query, where: cm.inserted_at >= ^from)

        _, query ->
          query
      end)

    query = from([_,cc, _,cm, ...] in query,
      select: {cm.inserted_at, cm.message ,cc.id})

    repo.all(query)
  end

  def calculate_after_call_response(disposition,to,from, loc_ids)do
    #    time_list = Enum.sort_by(get_deflected_time_list(), & elem(&1, 0), DateTime)
    time_list = get_call_time_list(disposition,to, from, loc_ids)
    msgs = get_messages(disposition,to,from, loc_ids)

    if List.first(time_list) && List.first(msgs)do
      time_list = Enum.chunk_by(time_list, &(elem(&1, 1)))
      time_list = Enum.map(time_list, fn x ->
        Enum.sort_by(x, & elem(&1, 0), DateTime)
      end) |> List.flatten()
      {_, _,count} = Enum.reduce(time_list, {nil, msgs, 0}, fn next, acc ->
        {prev, msg_list, count} = acc
        if prev ==  nil do
          {next, msg_list, count}
        else
          {prev_date, prev_call_id} = prev
          {next_date, next_call_id} = next
          if prev_call_id == next_call_id do
            if Timex.between?(next_date, prev_date, Timex.shift(prev_date, hours: 24)) do
              res = Enum.filter(msg_list, fn {t, _, id} -> Timex.between?(DateTime.from_naive!(t, "Etc/UTC"), prev_date, next_date) && id == prev_call_id end) |> Enum.count()
              if res > 0 do
                {next, msg_list, count=count+1}
              else
                {next, msg_list, count}
              end
            else
              res = Enum.filter(msg_list, fn {t, _, id} -> Timex.between?(DateTime.from_naive!(t, "Etc/UTC"), prev_date, Timex.shift(prev_date, hours: 24)) && id == prev_call_id end) |> Enum.count()
              if res > 0 do
                {next, msg_list, count=count+1}
              else
                {next, msg_list, count}
              end
            end
          else
            if (Enum.filter(msg_list, fn {t , _, id} -> Timex.between?(DateTime.from_naive!(t, "Etc/UTC"), prev_date, Timex.shift(prev_date, hours: 24)) && prev_call_id == id end)) |>  Enum.count() > 0 do
              {next, msg_list, count= count+1}
            else
              {next, msg_list, count}
            end
          end
        end

        #     {t1, count} = acc
        #     {time, call_id} = t
        #      if (Enum.filter(t1, fn {x , _, id} -> DateTime.from_naive!(x, "Etc/UTC") > time && call_id == id end)) |>  Enum.count() > 0 do
        #        {msgs , count = count + 1}
        #        else
        #        acc
        #     end
      end)
      {prev_date, prev_call_id} = List.last(time_list)
      if (Enum.filter(msgs, fn {t , _, id} -> Timex.between?(DateTime.from_naive!(t, "Etc/UTC"), prev_date, Timex.shift(prev_date, hours: 24)) && prev_call_id == id end)) |>  Enum.count() > 0 do
        count = count + 1
      else
        count
      end

    else
      0
    end

  end
end
