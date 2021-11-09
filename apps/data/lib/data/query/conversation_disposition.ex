defmodule Data.Query.ConversationDisposition do
  @moduledoc """
  Module for the Conversation Disposition queries
  """

  alias Data.Schema.{Conversation, Disposition, ConversationDisposition, ConversationCall}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Ecto.Adapters.SQL
  import Ecto.Query

  @cols [
    :disposition_count,
    :disposition_date,
    :channel_type
  ]

  @query1 "SELECT * FROM count_team_dispositions_by_channel_type($1, $2);"
  @query2 "SELECT * FROM count_location_dispositions_by_channel_type($1, $2);"
  @query3 "SELECT * FROM count_dispositions_by_channel_type($1);"

  @doc """
  Creates a new conversation disposition
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationDisposition.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ConversationDisposition{}
    |> ConversationDisposition.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @spec count_all_by_channel_type(
          channel_type :: String.t(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: String.t()
  def count_all_by_channel_type(channel_type, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
    if channel_type == "CALL" do
      from(c in ConversationDisposition,
      where: not is_nil(c.conversation_call_id),
        join: d in Disposition,
        on: c.disposition_id == d.id,
        where: d.disposition_name  in ["Call Deflected","Call deflected","Call Transferred","Call Hang Up"]
      )
    else
        from(c in Conversation,
          join: cd in ConversationDisposition,
          on: c.id == cd.conversation_id,
          join: d in Disposition,
          on: cd.disposition_id == d.id,
          where: c.channel_type == ^channel_type,
          where: d.disposition_name not in ["Call Deflected","Call deflected","Call Transferred","Call Hang Up"]
        )
    end


    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to), do: query, else: from([c, ...] in query, where: c.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from), do: query, else: from([c, ...] in query, where: c.inserted_at >= ^from)

        _, query ->
          query
      end)

    query=from([c, ...] in query,
      distinct: [c.id],
      select: %{a: c.inserted_at}
    )

    repo.all(query)
  end

  @spec count_channel_type_by_location_ids(
          channel_type :: String.t(),
          location_ids :: [String.t()],
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: String.t()
  def count_channel_type_by_location_ids(channel_type, location_ids, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
    if channel_type == "CALL" do
      from(c in ConversationDisposition,
      join: cc in ConversationCall, on: cc.id == c.conversation_call_id,
        where: cc.location_id in ^location_ids,
        join: d in Disposition,
        on: c.disposition_id == d.id,
        where: d.disposition_name  in ["Call Deflected","Call deflected","Call Transferred","Call Hang Up"]
      )
    else
      from(c in Conversation,
        join: cd in ConversationDisposition,
        on: c.id == cd.conversation_id,
        join: d in Disposition,
        on: cd.disposition_id == d.id,
        where: c.location_id in ^location_ids and c.channel_type == ^channel_type,
        where: d.disposition_name not in ["Call Deflected","Call deflected","Call Transferred","Call Hang Up"]
      )
    end
    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to), do: query, else: from([c, ...] in query, where: c.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from), do: query, else: from([c, ...] in query, where: c.inserted_at >= ^from)

        _, query ->
          query
      end)

    query=from([c, ...] in query,
      distinct: [c.id],
      select: %{a: c.inserted_at}
    )

    repo.all(query)
  end


  defp get_date(time_stamp) do
    Timex.to_date(time_stamp)
  end

  @spec count_channel_type_by_team_id(
          channel_type :: String.t(),
          team_id :: String.t(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: String.t()
  def count_channel_type_by_team_id(channel_type, team_id, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
    if channel_type == "CALL" do
      from(c in ConversationDisposition,
        join: cc in ConversationCall, on: cc.id == c.conversation_call_id,
        join: d in Disposition, on: c.disposition_id == d.id,
        where: d.team_id == ^team_id,
        where: d.disposition_name  in ["Call Deflected","Call deflected","Call Transferred","Call Hang Up"]
      )
    else
        from(c in Conversation,
          join: cd in ConversationDisposition,
          on: c.id == cd.conversation_id,
          join: d in Disposition,
          on: cd.disposition_id == d.id,
          where: d.team_id == ^team_id and c.channel_type == ^channel_type,
          where: d.disposition_name not in ["Call Deflected","Call deflected","Call Transferred","Call Hang Up"]
        )
    end


    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to), do: query, else: from([c, ...] in query, where: c.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from), do: query, else: from([c, ...] in query, where: c.inserted_at >= ^from)

        _, query -> query
      end)

    from([c, ...] in query,
      distinct: c.id,
      select: c.id
    )
    |> repo.all()
    |> Enum.count()
  end

end
