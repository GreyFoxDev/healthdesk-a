defmodule Data.Query.Team do
  @moduledoc """
  Module for the Team queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Team, Location}
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @doc """
  Returns all active teams
  """
  @spec all(repo :: Ecto.Repo.t()) :: [Team.t()]
  def all(repo \\ Read) do
    from(t in Team,
      where: is_nil(t.deleted_at),
      left_join: l in Location,
      on: t.id == l.team_id and is_nil(l.deleted_at),
      left_join: m in assoc(t, :team_members),
      left_join: c in assoc(l, :conversations),
      preload: [locations: {l, :conversations}, team_members: m],
      order_by: [t.team_name, l.location_name, c.started_at]
    )
    |> repo.all()
  end

  @doc """
  Returns a team by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Team.t() | nil
  def get(id, repo \\ Read) do
    sub = from(l in Location, where: is_nil(l.deleted_at))

    from(t in Team,
      where: t.id == ^id,
      left_join: l in assoc(t, :locations),
      left_join: m in assoc(t, :team_members),
      preload: [locations: ^sub, team_members: m],
      order_by: [t.team_name, l.location_name],
      limit: 1
    )
    |> repo.one()
  end

  @doc """
  Creates a new team
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Team{}
    |> Team.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing team
  """
  @spec update(team :: Team.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update(%Team{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Team.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a team. This is a logical delete
  """
  @spec delete(team :: Team.t(), repo :: Ecto.Repo.t()) ::
          {:ok, Team.t()} | {:error, :no_record_found}
  def delete(%Team{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %Team{} = team ->
        update(team, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
