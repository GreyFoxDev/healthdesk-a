defmodule Data.Query.Disposition do
  @moduledoc """
  Module for the Disposition queries
  """
  import Ecto.Query

  alias Data.Schema.Disposition
  alias Data.Schema.Conversation
  alias Data.Query.Disposition, as: Dispositions
  alias Data.Schema.ConversationDisposition
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a disposition by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Disposition.t() | nil
  def get(id, repo \\ Read) do
    from(t in Disposition,
      where: is_nil(t.deleted_at),
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of active dispositions for a team
  """
  @spec get_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [Disposition.t()]
  def get_by_team_id(team_id, repo \\ Read) do
    from(t in Disposition,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id
    )
    |> repo.all()
  end

  @doc """
  Return a list of active dispositions for a team
  """
  @spec get_by_team_and_name(team_id :: binary(), name :: binary(), repo :: Ecto.Repo.t()) :: [
          Disposition.t()
        ]
  def get_by_team_and_name(team_id, name, repo \\ Read) do
    from(t in Disposition,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id and t.disposition_name == ^name
    )
    |> repo.all()
  end

  @doc """
  Return a list of all dispositions with count of usage. Used by super admin
  """
  @spec count_all(repo :: Ecto.Repo.t()) :: [map()]
  def count_all(repo \\ Read) do
    from(d in Data.Schema.Disposition,
      join: cd in assoc(d, :conversation_dispositions),
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id), date: fragment("?::date", cd.inserted_at)}
    )
    |> repo.all()
  end

  @doc """
  Return a list of all dispositions with count of usage. Used by super admin with to and from filters
  """
  @spec count_all_by(to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: [map()]
  def count_all_by(to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(d in Disposition,
        join: cd in assoc(d, :conversation_dispositions)
      )

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
            do: query,
            else: from([_, cd, ...] in query, where: cd.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
            do: query,
            else: from([_, cd, ...] in query, where: cd.inserted_at >= ^from)

        _, query ->
          query
      end)

    from([d, cd] in query,
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id), date: fragment("?::date", cd.inserted_at)
      }
    )
    |> repo.all()
  end

  @doc """
  Return a list of dispositions with count of usage by team
  """
  @spec count_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [map()]
  def count_by_team_id(team_id, repo \\ Read) do
    from(d in Disposition,
      join: cd in assoc(d, :conversation_dispositions),
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      where: d.team_id == ^team_id,
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id)}
    )
    |> repo.all()
  end

  @doc """
  Return a list of dispositions with count of usage by team, with to and from filters
  """
  @spec count_by_team(
          team_id :: binary(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: [map()]
  def count_by_team(team_id, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(d in Disposition,
        join: cd in assoc(d, :conversation_dispositions)
      )

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
            do: query,
            else: from([_, cd, ...] in query, where: cd.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
            do: query,
            else: from([_, cd, ...] in query, where: cd.inserted_at >= ^from)

        _, query ->
          query
      end)

    from(
      [d, cd] in query,
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      where: d.team_id == ^team_id,
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id)}
    )
    |> repo.all()
  end

  #  @doc """
  #  Return a list of dispositions with count of usage by location
  #  """
  #  @spec count_by_location_id(location_id :: binary(), to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: [map()]
  #  def count_by_location_id(location_id, to, from, repo \\ Read) do
  #    to = Data.Disposition.convert_string_to_date(to)
  #    from = Data.Disposition.convert_string_to_date(from)
  #    query = from(d in Disposition,
  #      join: cd in assoc(d, :conversation_dispositions),
  #      join: c in assoc(cd, :conversation)
  #    )
  #    query = Enum.reduce(%{to: to, from: from}, query, fn
  #      {:to, to}, query ->
  #        if is_nil(to), do: query, else: from([d, cd, c] in query, where: cd.inserted_at <= ^to)
  #      {:from, from}, query ->
  #        if is_nil(from), do: query, else: from([d, cd, c] in query, where: cd.inserted_at >= ^from)
  #      _, query -> query
  #    end)
  #    from([d, cd, c] in query,
  #      group_by: [d.disposition_name, cd.conversation_id, cd.disposition_id, cd.inserted_at],
  #      where: c.location_id == ^location_id,
  #      distinct: [cd.conversation_id, cd.disposition_id, cd.inserted_at],
  #      order_by: d.disposition_name,
  #      select: %{name: d.disposition_name, count: count(cd.id)}
  #    )
  #    |> repo.all()
  #  end

  @doc """
  Return a list of dispositions with count by location_id and dates
  """
  @spec get_by(
          location_id :: binary(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: [map()]
  def get_by(location_ids, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(d in Disposition,
        join: cd in assoc(d, :conversation_dispositions),
        join: c in assoc(cd, :conversation)
      )

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
            do: query,
            else: from([_, cd, ...] in query, where: cd.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
            do: query,
            else: from([_, cd, ...] in query, where: cd.inserted_at >= ^from)

        _, query ->
          query
      end)

    from([d, cd, c] in query,
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      where: c.location_id in ^location_ids,
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id), date: fragment("?::date", cd.inserted_at) }
    )
    |> repo.all()
  end

  @doc """
  Return a list of dispositions  dates
  """
  @spec get_by1(
          location_id :: binary(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: [map()]
  def get_by1(location_ids, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(d in Disposition,
        join: cd in assoc(d, :conversation_dispositions),
        join: c in assoc(cd, :conversation)
      )

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_, cd, ...] in query, where: cd.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_, cd, ...] in query, where: cd.inserted_at >= ^from)

        _, query ->
          query
      end)

    from([d, cd, c] in query,
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      where: c.location_id in ^location_ids,
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id)}
    )
    |> repo.all()
  end

  def count(disposition_id, repo \\ Read) do
    from(cd in ConversationDisposition,
      join: d in Disposition,
      on: cd.disposition_id == d.id,
      where: d.id == ^disposition_id,
      select: count(cd.id)
    )
    |> repo.one()
  end

  def average_per_day(params, repo \\ Read) do
    query =
      from(cd in ConversationDisposition,
        group_by: fragment("date_trunc('day',?)", cd.inserted_at),
        select: %{count: count(cd.id)}
      )

    query =
      Enum.reduce(params, query, fn {key, value}, query ->
        case key do
          "to" ->
            to = Data.Disposition.convert_string_to_date(value)

            if is_nil(to),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at <= ^to
                )

          "from" ->
            from = Data.Disposition.convert_string_to_date(value)

            if is_nil(from),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at >= ^from
                )

          _ ->
            query
        end
      end)

    from(f in subquery(query), select: avg(f.count))
    |> repo.one
    |> format_avg()
  end

  #  def average_per_day(repo\\ Read) do
  #    repo
  #    |> SQL.query!("SELECT average_dispositions_per_day() AS #{:sessions_per_day};")
  #    |> build_results()
  #  end

  def average_per_day_for_team(%{"team_id" => team_id} = params, repo \\ Read) do
    query =
      from(cd in ConversationDisposition,
        join: d in Disposition,
        on: d.id == cd.disposition_id,
        where: d.team_id == ^team_id,
        group_by: [d.team_id, fragment("date_trunc('day',?)", cd.inserted_at)],
        select: %{count: count(cd.id)}
      )

    query =
      Enum.reduce(params, query, fn {key, value}, query ->
        case key do
          "to" ->
            to = Data.Disposition.convert_string_to_date(value)

            if is_nil(to),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at <= ^to
                )

          "from" ->
            from = Data.Disposition.convert_string_to_date(value)

            if is_nil(from),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at >= ^from
                )

          _ ->
            query
        end
      end)

    from(d in subquery(query), select: avg(d.count))
    |> repo.one
    |> format_avg()
  end

  #  def average_per_day_for_team(team_id, repo \\ Read) do #5, 7
  #    repo
  #    |> SQL.query!("SELECT * FROM average_dispositions_per_day_by_team();")
  #    |> build_results()
  #    |> Enum.filter(&(&1.team_id == team_id))
  #  end

  def average_per_day_for_location(%{"location_id" => location_id} = params, repo \\ Read) do
    query =
      from(cd in ConversationDisposition,
        join: c in Conversation,
        on: c.id == cd.conversation_id,
        where: c.location_id == ^location_id,
        group_by: fragment("date_trunc('day',?)", cd.inserted_at),
        select: %{count: count(cd.id)}
      )

    query =
      Enum.reduce(params, query, fn {key, value}, query ->
        case key do
          "to" ->
            to = Data.Disposition.convert_string_to_date(value)

            if is_nil(to),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at <= ^to
                )

          "from" ->
            from = Data.Disposition.convert_string_to_date(value)

            if is_nil(from),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at >= ^from
                )

          _ ->
            query
        end
      end)

    from(c in subquery(query), select: avg(c.count))
    |> repo.one
    |> format_avg()
  end

  def average_per_day_for_locations(%{"location_ids" => location_ids} = params, repo \\ Read) do
    query =
      from(cd in ConversationDisposition,
        join: c in Conversation,
        on: c.id == cd.conversation_id,
        where: c.location_id in ^location_ids,
        group_by: fragment("date_trunc('day',?)", cd.inserted_at),
        select: %{count: count(cd.id)}
      )

    query =
      Enum.reduce(params, query, fn {key, value}, query ->
        case key do
          "to" ->
            to = Data.Disposition.convert_string_to_date(value)

            if is_nil(to),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at <= ^to
                )

          "from" ->
            from = Data.Disposition.convert_string_to_date(value)

            if is_nil(from),
              do: query,
              else:
                from([cd, ...] in query,
                  where: cd.inserted_at >= ^from
                )

          _ ->
            query
        end
      end)

    from(c in subquery(query), select: avg(c.count))
    |> repo.one
    |> format_avg()
  end

  #  def average_per_day_for_location(location_id, repo \\ Read) do
  #    repo
  #    |> SQL.query!("SELECT * FROM average_dispositions_per_day_by_location();")
  #    |> build_results()
  #    |> Enum.filter(&(&1.location_id == location_id))
  #  end

  @doc """
  Creates a new disposition
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Disposition.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Disposition{}
    |> Disposition.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing disposition
  """
  @spec update(disposition :: Disposition.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Disposition.t()} | {:error, Ecto.Changeset.t()}
  def update(%Disposition{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Disposition.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a disposition. This is a logical delete
  """
  @spec delete(disposition :: Disposition.t(), repo :: Ecto.Repo.t()) ::
          {:ok, Disposition.t()} | {:error, :no_record_found}
  def delete(%Disposition{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %Disposition{} = disposition ->
        Dispositions.update(disposition, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end

  defp build_results(results) do
    cols = Enum.map(results.columns, &String.to_existing_atom/1)
    Enum.map(results.rows, fn row -> Map.new(Enum.zip(cols, row)) end)
  end

  defp format_avg(avg) do
    if is_nil(avg) do
      [%{sessions_per_day: 0}]
    else
      sessions = trunc(avg.coef * :math.pow(10, avg.exp))
      [%{sessions_per_day: sessions}]
    end
  end

  def get_call_related_by(location_ids, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(d in Disposition,
        join: cd in assoc(d, :conversation_dispositions),
        join: cc in Data.Schema.ConversationCall, on: cd.conversation_call_id == cc.id
      )

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([_, cd, ...] in query, where: cd.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([_, cd, ...] in query, where: cd.inserted_at >= ^from)

        _, query ->
          query
      end)

    from([d, cd, cc] in query,
      group_by: [
        d.disposition_name,
        cd.conversation_id,
        cd.conversation_call_id,
        cd.disposition_id,
        cd.inserted_at
      ],
      where: cc.location_id in ^location_ids,
      distinct: [cd.conversation_id, cd.conversation_call_id, cd.disposition_id, cd.inserted_at],
      order_by: d.disposition_name,
      select: %{name: d.disposition_name, count: count(cd.id), date: fragment("?::date", cd.inserted_at) }
    )
    |> repo.all()
  end
end
