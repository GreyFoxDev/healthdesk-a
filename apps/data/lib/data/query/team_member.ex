defmodule Data.Query.TeamMember do
  @moduledoc """
  Module for the Team Member queries
  """
  import Ecto.Query, only: [from: 2]
  import Data.TimezoneOffset

  alias Data.Schema.{TeamMember, Team, User, TeamMemberLocation, Location}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Ecto.Adapters.SQL

  @available_function "SELECT * FROM find_available_team_members($1, $2);"

  @doc """
  Return a list of active locations
  """
  @spec all(repo :: Ecto.Repo.t()) :: [TeamMember.t()]
  def all(repo \\ Read) do
    from(t in TeamMember,
      join: u in User,
      join: r in Team,
      where: is_nil(t.deleted_at),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: is_nil(r.deleted_at),
      order_by: [u.first_name, u.last_name],
      preload: [ user: u]
    )
    |> repo.all()
  end

  @doc """
  Returns a team member by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: TeamMember.t() | nil
  def get(id, repo \\ Read) do
    from(t in TeamMember,
      join: u in User,
      join: r in Team,
      where: is_nil(r.deleted_at),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: t.id == ^id,
      preload: [:team_member_locations, :user],
      limit: 1
    )
    |> repo.one()
  end

  @doc """
  Return a list of active team members for a team
  """
  @spec get_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [TeamMember.t()]
  def get_by_team_id(team_id, repo \\ Read) do
    from(t in TeamMember,
      join: u in User,
      join: r in Team,
      where: is_nil(r.deleted_at),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: t.team_id == ^team_id,
      order_by: [u.first_name, u.last_name],
      distinct: t.id,
      preload: [:team_member_locations, :user]
    )
    |> repo.all()
  end

  @doc """
  Return a list of active team members for a location
  """
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [TeamMember.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in TeamMember,
      inner_join: u in User,
      inner_join: r in Team,
      inner_join: l in TeamMemberLocation,
      where: is_nil(t.deleted_at),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where:  t.location_id == ^location_id,
      or_where: l.location_id == ^location_id,
      order_by: [u.first_name, u.last_name],
      distinct: u.id,
      preload: [ :user]
    )
    |> repo.all()
    |> Enum.uniq_by(& &1.id)
  end

  @doc """
  Returns a list of available team members for a location
  """
  @spec get_available_by_location(
          location :: Location.t(),
          time_string :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: [map()]
  def get_available_by_location(location, current_time, repo \\ Read) do
    repo
    |> SQL.query!(@available_function, [location.id, current_time])
    |> build_results()
  end

  @doc """
  Creates a new team member
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %TeamMember{}
    |> TeamMember.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing team member
  """
  @spec update(team_member :: TeamMember.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, TeamMember.t()} | {:error, Ecto.Changeset.t()}
  def update(%TeamMember{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> TeamMember.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a team member. This is a logical delete
  """
  @spec delete(team_member :: TeamMember.t(), repo :: Ecto.Repo.t()) ::
          {:ok, TeamMember.t()} | {:error, :no_record_found}
  def delete(%TeamMember{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %TeamMember{} = location ->
        update(location, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end

  @doc """
  Associate a team member with a list of locations ids
  """
  @spec associate_locations(id :: binary(), [binary()], repo :: Ecto.Repo.t()) :: [
          TeamMemberLocation.t()
        ]
  def associate_locations(id, locations, repo \\ Write) do
    from(m in TeamMemberLocation, where: m.team_member_id == ^id) |> repo.delete_all()

    Enum.map(locations, fn location ->
      %TeamMemberLocation{}
      |> TeamMemberLocation.changeset(%{location_id: location, team_member_id: id})
      |> repo.insert!()
    end)
  end

  defp build_results(results) do
    cols = Enum.map(results.columns, &String.to_existing_atom/1)
    Enum.map(results.rows, fn row -> Map.new(Enum.zip(cols, row)) end)
  end
end
