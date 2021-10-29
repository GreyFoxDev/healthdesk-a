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

    from([c, ...] in query,
      distinct: [c.id],
      select: c.id
    )

    repo.all(query) |> Enum.count()
  end

  @spec count_all_by_channel_type_and_days(
          channel_type :: String.t(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: String.t()
  def count_all_by_channel_type_and_days(channel_type, to, from, repo \\ Read) do
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

    query=from([c,cd, ...] in query,
      select: %{a: cd.inserted_at}
    )

    repo.all(query) |> get_data_for_line_graph(to, from)

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
      select: c.id
    )

    repo.all(query) |> Enum.count()
  end

  def channel_type_by_location_ids_and_days(channel_type, location_ids, to, from, repo \\ Read) do
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

    query = from(
      [c, cd, ...] in query,
      distinct: [c.id],
      select: %{
        a: c.inserted_at
      }
    )

    repo.all(query) |> get_data_for_line_graph(to, from)


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

  defp build_results(results) do
    Enum.map(results.rows, fn row -> Map.new(Enum.zip(@cols, row)) end)
  end
  defp get_data_for_line_graph(results, to, from) do
    results=Enum.frequencies_by(results, fn date -> DateTime.from_naive!(date.a, "Etc/UTC")|>DateTime.to_date() end) |> Map.to_list()
    days = case %{to: to, from: from} do
      %{to: nil, from: nil} ->
        Enum.map(0..-6, &Date.add(DateTime.utc_now(), &1))
      %{to: nil, from: from} ->
        range = Date.range(from, DateTime.utc_now())
        Enum.map(range, fn (x) -> x end)
      %{to: to, from: nil} ->
        oldest = Enum.min_by(results, fn x -> elem(x, 0) end, Date)
        range = Date.range(oldest, to)
        Enum.map(range, fn (x) -> x end)
      %{to: to, from: from} ->
        range = Date.range(from, to)
        Enum.map(range, fn (x) -> x end)
    end
    results = Enum.map(
      days,
      fn y ->
        if(t = Enum.find(results, fn x -> elem(x, 0) == y end)) do
          [y,elem(t, 1)]
        else
          [y,0]
        end
      end
    )
  end
end
