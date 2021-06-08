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

  @spec get_by_team_member_id(team_member_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_team_member_id(team_member_id, repo \\ Read) do
    from(t in Ticket,
      where: t.team_member_id == ^team_member_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec get_by_team_member_and_location_id(team_member_id :: binary(), location_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_team_member_and_location_id(team_member_id, location_id, repo \\ Read) do
    from(t in Ticket,
      where: t.team_member_id == ^team_member_id,
      where: t.location_id == ^location_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec get_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_team_id(team_id, repo \\ Read) do
    from(t in Ticket,
      join: tm in TeamMember, on: t.team_member_id == tm.id,
      where: tm.team_id == ^team_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec get_by_team_and_location_id(team_id :: binary(), location_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_team_and_location_id(team_id, location_id, repo \\ Read) do
    from(t in Ticket,
      join: tm in TeamMember, on: t.team_member_id == tm.id,
      where: tm.team_id == ^team_id,
      where: t.location_id == ^location_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec all_tickets(repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def all_tickets(repo \\ Read) do
    from(t in Ticket,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in Ticket,
      where: t.location_id == ^location_id,
      where: t.status == "open"
    )
    |> repo.all()
  end

  @spec get_by_admin_location(team_member_id :: binary(), repo :: Ecto.Repo.t()) :: [Ticket.t()]
  def get_by_admin_location(team_member_id, repo \\ Read) do
    from(t in Ticket,
      join: tl in TeamMemberLocation, on: t.location_id == tl.location_id,
      where: tl.team_member_id == ^team_member_id,
      where: t.status == "open"
    )
    |> repo.all()
  end
end
