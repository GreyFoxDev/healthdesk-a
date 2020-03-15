defmodule Data.Query.Disposition do
  @moduledoc """
  Module for the Disposition queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Disposition
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write
  alias Ecto.Adapters.SQL

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
  Return a list of all dispositions with count of usage. Used by super admin
  """
  @spec count_all(repo :: Ecto.Repo.t()) :: [map()]
  def count_all(repo \\ Read) do
    from(d in Data.Schema.Disposition,
      join: cd in assoc(d, :conversation_dispositions),
      group_by: [d.disposition_name, cd.conversation_id, cd.disposition_id, cd.inserted_at],
      distinct: [cd.conversation_id, cd.disposition_id, cd.inserted_at],
      select: %{name: d.disposition_name, count: count(cd.id)}
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
      group_by: [d.disposition_name, cd.conversation_id, cd.disposition_id, cd.inserted_at],
      where: d.team_id == ^team_id,
      distinct: [cd.conversation_id, cd.disposition_id, cd.inserted_at],
      select: %{name: d.disposition_name, count: count(cd.id)}
    )
    |> repo.all()
  end

  @doc """
  Return a list of dispositions with count of usage by location
  """
  @spec count_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [map()]
  def count_by_location_id(location_id, repo \\ Read) do
    from(d in Disposition,
      join: cd in assoc(d, :conversation_dispositions),
      join: c in assoc(cd, :conversation),
      group_by: [d.disposition_name, cd.conversation_id, cd.disposition_id, cd.inserted_at],
      where: c.location_id == ^location_id,
      distinct: [cd.conversation_id, cd.disposition_id, cd.inserted_at],
      select: %{name: d.disposition_name, count: count(cd.id)}
    )
    |> repo.all()
  end

  def count(disposition_id, repo \\ Read) do
    from(cd in Data.Schema.ConversationDisposition,
      join: d in Disposition,
      on: cd.disposition_id == d.id,
      where: d.id == ^disposition_id,
      select: count(cd.id)
    )
    |> repo.one()
  end

  def average_per_day(repo \\ Read) do
    repo
    |> SQL.query!("SELECT average_dispositions_per_day() AS #{:sessions_per_day};")
    |> build_results()
  end

  def average_per_day_for_team(team_id, repo \\ Read) do
    repo
    |> SQL.query!("SELECT * FROM average_dispositions_per_day_by_team();")
    |> build_results()
    |> Enum.filter(&(&1.team_id == team_id))
  end

  def average_per_day_for_location(location_id, repo \\ Read) do
    repo
    |> SQL.query!("SELECT * FROM average_dispositions_per_day_by_location();")
    |> build_results()
    |> Enum.filter(&(&1.location_id == location_id))
  end

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
        update(disposition, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end

  defp build_results(results) do
    cols = Enum.map(results.columns, &String.to_existing_atom/1)
    Enum.map(results.rows, fn row -> Map.new(Enum.zip(cols, row)) end)
  end
end
