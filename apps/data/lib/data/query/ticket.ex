defmodule Data.Query.Ticket do
  @moduledoc """
  Module for the Ticket queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Ticket
  alias Data.Schema.TeamMember
  alias Data.Schema.TeamMemberLocation
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Data.Disposition

  @doc """
  Returns a ticket by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Ticket.t() | nil
  def get(id, repo \\ Read) do
    from(t in Ticket,
      where: t.id == ^id,
      preload: [:user, :location, team_member: [:user], notes: [:user]]
    )
    |> repo.one()
  end

  @doc """
  Creates a new Ticket
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Ticket.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Ticket{}
    |> Ticket.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing Ticket
  """
  @spec update(notification :: Ticket.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Ticket.t()} | {:error, Ecto.Changeset.t()}
  def update(%Ticket{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Ticket.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Get Tickets for location_ids
  """
  @spec get_by_location_ids(location_id :: [binary()], repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_location_ids(location_id, repo \\ Read) do
    from(t in Ticket,
      where: t.location_id in ^location_id,
      where: t.status != "archive",
      order_by: [desc: t.updated_at],
      preload: [:user, :location, team_member: [:user], notes: [:user]],
      limit: 100
    )
    |> repo.all()
  end

  @doc """
  Get opened Tickets for for team-member
  """
  @spec get_by_team_member_id(team_member_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_team_member_id(team_member_id, repo \\ Read) do
    from(t in Ticket,
      where: t.team_member_id == ^team_member_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @doc """
  Get opened Tickets for team-member and location.
  """
  @spec get_by_team_member_and_location_id(
          team_member_id :: binary(),
          location_id :: binary(),
          repo :: Ecto.Repo.t()
        ) :: [Ticket.t()]
  def get_by_team_member_and_location_id(team_member_id, location_id, repo \\ Read) do
    from(t in Ticket,
      where: t.team_member_id == ^team_member_id,
      where: t.location_id == ^location_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  #  @doc """
  #  Return a list of tickets with count by location and date-time.
  #  """
  #  @spec count_by(params :: map(), repo :: Ecto.Repo.t()) :: [map()]
  #  def count_by(params, repo \\ Read) do
  #    to = Data.Disposition.convert_string_to_date(params["to"])
  #    from = Data.Disposition.convert_string_to_date(params["from"])
  #
  #    query = from(t in Ticket,
  #      join: tm in TeamMember, on: t.team_member_id == tm.id,
  #      join: tl in TeamMemberLocation, on: t.location_id == tl.location_id,
  #    )
  #    query = Enum.reduce(params, query, fn
  #      %{"to" => to}, query ->
  #        if is_nil(to), do: query, else: from([t,...] in query, where: t.inserted_at <= ^to)
  #      %{"from" => from}, query ->
  #        if is_nil(from), do: query, else: from([t,...] in query, where: t.inserted_at >= ^from)
  #      %{"team_id" => team_id}, query ->
  #        if is_nil(team_id), do: query, else: from([...,tm,tl] in query, where: tm.team_id == ^team_id)
  #      %{"location_id" => location_id}, query ->
  #        if is_nil(location_id), do: query, else: from([t,...] in query, where: t.location_id == ^location_id)
  #      %{"team_member_id" => team_member_id}, query ->
  #        if is_nil(team_member_id), do: query, else: from([...,tl] in query, where: tl.team_member_id == ^team_member_id)
  #      _, query -> query
  #    end)
  #    from([t, tm, tl] in query,
  #      where: t.status == "open"
  #    )
  #    |> repo.all()
  #  end

  @doc """
  Get opened Tickets for specific team.
  """
  @spec get_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_team_id(team_id, repo \\ Read) do
    from(t in Ticket,
      join: tm in TeamMember,
      on: t.team_member_id == tm.id,
      where: tm.team_id == ^team_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @doc """
  Get opened Tickets for specific team and location.
  """
  @spec get_by_team_and_location_id(
          team_id :: binary(),
          location_id :: binary(),
          repo :: Ecto.Repo.t()
        ) :: [Ticket.t()]
  def get_by_team_and_location_id(team_id, location_id, repo \\ Read) do
    from(t in Ticket,
      join: tm in TeamMember,
      on: t.team_member_id == tm.id,
      where: tm.team_id == ^team_id,
      where: t.location_id == ^location_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @doc """
  Get all opened Tickets.
  """
  @spec all_tickets(repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def all_tickets(repo \\ Read) do
    from(t in Ticket,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @doc """
  Get opened Tickets for specific location_id.
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in Ticket,
      where: t.location_id == ^location_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @doc """
  Get opened Tickets for admin location.
  """
  @spec get_by_admin_location(team_member_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_admin_location(team_member_id, repo \\ Read) do
    from(t in Ticket,
      join: tl in TeamMemberLocation,
      on: t.location_id == tl.location_id,
      where: tl.team_member_id == ^team_member_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec filter(params :: map(), repo :: Ecto.Repo.t()) :: [Ticket.t()]

  def filter(params, repo \\ Read) do
    query =
      from(t in Ticket,
        where: t.status == "open",
        distinct: t.id
        #      group_by: t.id,
        #      select: count(t.id)
      )

    query =
      Enum.reduce(params, query, fn {key, value}, query ->
        case key do
          "team_id" when is_nil(value) == false and value != "" ->
            from(t in query,
              join: tm in TeamMember,
              on: t.team_member_id == tm.id,
              where: tm.team_id == ^value
            )

          "team_member_id" when is_nil(value) == false and value != "" ->
            from(t in query,
              join: tl in TeamMemberLocation,
              on: t.location_id == tl.location_id,
              where: tl.team_member_id == ^value
            )

          "location_ids" when is_nil(value) == false and value != "" ->
            from(t in query, where: t.location_id in ^value)

          "to" when is_nil(value) == false or value != "" ->
            to = Disposition.convert_string_to_date(value)

            if is_nil(to),
              do: query,
              else:
                from([t, ...] in query,
                  where: t.inserted_at <= ^to
                )

          "from" when is_nil(value) == false and value != "" ->
            from = Disposition.convert_string_to_date(value)

            if is_nil(from),
              do: query,
              else:
                from([t, ...] in query,
                  where: t.inserted_at >= ^from
                )

          _ ->
            query
        end
      end)

    repo.all(query)
    |> Enum.count()
  end
end
