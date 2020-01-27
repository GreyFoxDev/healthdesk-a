defmodule Data.Query.TeamMember do
  @moduledoc """
  Module for the Team Member queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{TeamMember, User, TeamMemberLocation}
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @doc """
  Return a list of active locations
  """
  @spec all(repo :: Ecto.Repo.t()) :: [TeamMember.t()]
  def all(repo \\ Read) do
    from(t in TeamMember,
      join: u in User,
      left_join: l in assoc(t, :team_member_locations),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: is_nil(t.deleted_at),
      order_by: [u.first_name, u.last_name],
      preload: [locations: l, user: u]
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
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: t.team_id == ^team_id,
      order_by: [u.first_name, u.last_name],
      preload: [:team_member_locations, :user]
    )
    |> repo.all()
  end

  @doc """
  Return a list of active team members for a location
  """
  @spec get_by_location_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [TeamMember.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(t in TeamMember,
      join: u in User,
      left_join: l in assoc(t, :team_member_locations),
      where: t.user_id == u.id,
      where: is_nil(u.deleted_at),
      where: l.location_id == ^location_id or t.location_id == ^location_id,
      order_by: [u.first_name, u.last_name],
      preload: [:team_member_locations, :user]
    )
    |> repo.all()
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
end
