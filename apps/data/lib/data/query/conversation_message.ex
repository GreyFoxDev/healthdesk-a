defmodule Data.Query.ConversationMessage do
  @moduledoc """
  Module for the Conversation Message queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{ConversationMessage, Conversation, Location}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Ecto.Adapters.SQL

  @doc """
  Returns a conversation message by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: ConversationMessage.t() | nil
  def get(id, repo \\ Read) do
    from(
      t in ConversationMessage,
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return median response time based on location
  """
  def count_by_location_id(location_ids, nil, nil, repo \\ Read) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_location_id('{#{Enum.join(location_ids,",")}}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  def count_by_location_id(location_ids, from, nil, repo) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_location_id_from('{#{Enum.join(location_ids,",")}}','#{from}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  def count_by_location_id(location_ids, nil, to, repo) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_location_id('{#{Enum.join(location_ids,",")}}','#{to}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  def count_by_location_id(location_ids, from, to, repo) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_location_id('{#{Enum.join(location_ids,",")}}','#{to}','#{from}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  @doc """
  Return median response time based on team
  """
  def count_by_team_id(team_id, nil, nil, repo \\ Read) do
    repo
    |> SQL.query!("SELECT count_messages_by_team_id('#{team_id}') AS #{:median_response_time}")
    |> build_results()
  end

  def count_by_team_id(team_id, from, nil, repo) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_team_id_from('#{team_id}','#{from}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  def count_by_team_id(team_id, nil, to, repo) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_team_id('#{team_id}','#{to}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  def count_by_team_id(team_id, from, to, repo) do
    repo
    |> SQL.query!(
      "SELECT count_messages_by_team_id('#{team_id}','#{to}','#{from}') AS #{:median_response_time}"
    )
    |> build_results()
  end

  @doc """
  Return a list of conversation messages for a conversation
  """
  @spec get_by_conversation_id(conversation_id :: binary(), repo :: Ecto.Repo.t()) :: [
          ConversationMessage.t()
        ]
  def get_by_conversation_id(conversation_id, repo \\ Read) do
    from(
      c in ConversationMessage,
      where: c.conversation_id == ^conversation_id,
      distinct: [c.sent_at],
      order_by: c.sent_at,
      select: c
    )
    |> repo.all()
  end

  def get_first_msg_by_convo_id(conversation_id, repo \\ Read) do
    from(
     c in ConversationMessage,
     where: c.conversation_id == ^conversation_id,
     order_by: c.sent_at,
     limit: 1,
     select: c.phone_number
    )
    |> repo.one()
  end

  @doc """
  Creates a new conversation message
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationMessage.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ConversationMessage{}
    |> ConversationMessage.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  mark a message as read
  """
  @spec mark_read(msg :: ConversationMessage.t(), repo :: Ecto.Repo.t()) :: [
          ConversationMessage.t()
        ]
  def mark_read(msg, repo \\ Write)

  def mark_read(%{read: false} = msg, repo) do
    cs =
      msg
      |> ConversationMessage.changeset(%{read: true})

    cs
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Returns a conversations per day by location_id
  """
  @spec count_incoming_messages_per_day_by_location_ids(id :: binary(),channel_type :: binary(),to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def count_incoming_messages_per_day_by_location_ids(ids, channel_type,to, from, repo \\ Read) do
    query = from(l in Location,
      left_join: c in Conversation,
      on: c.location_id==l.id,
      left_join: cm in ConversationMessage,
      on: c.id==cm.conversation_id,
      where: l.id in ^ids and cm.phone_number == c.original_number and c.channel_type==^channel_type
    )
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at >= ^from)

        _, query ->
          query
      end)

    query = from(
              [_, _, cm] in query,
              group_by: [fragment("?::date", cm.inserted_at)],
              select: [
                date: fragment("?::date", cm.inserted_at),
                count: count(fragment("?::date", cm.inserted_at))
              ]
            )
            |> repo.all()
  end

  @doc """
  Returns a conversations per day by location_id
  """
  @spec count_outgoing_messages_per_day_by_location_ids(id :: binary(),channel_type :: binary(),to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def count_outgoing_messages_per_day_by_location_ids(ids, channel_type,to, from, repo \\ Read) do
    query = from(l in Location,
      left_join: c in Conversation,
      on: c.location_id==l.id,
      left_join: cm in ConversationMessage,
      on: c.id==cm.conversation_id,
      where: l.id in ^ids and cm.phone_number != c.original_number and c.channel_type==^channel_type
    )
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at >= ^from)

        _, query ->
          query
      end)

    query = from(
              [_, _, cm] in query,
              group_by: [fragment("?::date", cm.inserted_at)],
              select: [
                date: fragment("?::date", cm.inserted_at),
                count: count(fragment("?::date", cm.inserted_at))
              ]
            )
            |> repo.all()
  end

 @doc """
  Returns a conversations per day
  """
  @spec count_incoming_messages_per_day(channel_type :: binary(),to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def count_incoming_messages_per_day(channel_type,to, from, repo \\ Read) do
    query = from(l in Location,
      left_join: c in Conversation,
      on: c.location_id==l.id,
      left_join: cm in ConversationMessage,
      on: c.id==cm.conversation_id,
      where: is_nil(l.deleted_at) and cm.phone_number == c.original_number and c.channel_type==^channel_type
    )
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at >= ^from)

        _, query ->
          query
      end)

    query = from(
              [_, _, cm] in query,
              group_by: [fragment("?::date", cm.inserted_at)],
              select: [
                date: fragment("?::date", cm.inserted_at),
                count: count(fragment("?::date", cm.inserted_at))
              ]
            )
            |> repo.all()
  end

  @doc """
  Returns a conversations per day
  """
  @spec count_outgoing_messages_per_day(channel_type :: binary(),to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def count_outgoing_messages_per_day(channel_type,to, from, repo \\ Read) do
    query = from(l in Location,
      left_join: c in Conversation,
      on: c.location_id==l.id,
      left_join: cm in ConversationMessage,
      on: c.id==cm.conversation_id,
      where: is_nil(l.deleted_at) and cm.phone_number != c.original_number and c.channel_type==^channel_type
    )
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_, _, cm] in query, where: cm.inserted_at >= ^from)

        _, query ->
          query
      end)

    query = from(
              [_, _, cm] in query,
              group_by: [fragment("?::date", cm.inserted_at)],
              select: [
                date: fragment("?::date", cm.inserted_at),
                count: count(fragment("?::date", cm.inserted_at))
              ]
            )
            |> repo.all()
  end



  def mark_read(%{read: true} = msg, _repo) do
    {:ok, msg}
  end

  def mark_read(msg, _repo) do
    {:ok, msg}
  end

  defp build_results(results) do
    cols = Enum.map(results.columns, &String.to_existing_atom/1)

    Enum.map(results.rows, fn row -> Map.new(Enum.zip(cols, row)) end)
    |> List.first()
  end


end
