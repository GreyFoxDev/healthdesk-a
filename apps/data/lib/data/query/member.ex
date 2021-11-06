defmodule Data.Query.Member do
  @moduledoc """
  Module for the Member queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Member,ConversationMessage, Location}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Return a list of active members
  """
  @spec all(repo :: Ecto.Repo.t()) :: [Member.t()]
  def all(repo \\ Read) do
    from(t in Member,
      where: is_nil(t.deleted_at)
    )
    |> repo.all()
  end

  @doc """
  Returns a member by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Member.t() | nil
  def get(id, repo \\ Read) do
    from(t in Member,
      where: is_nil(t.deleted_at),
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of active members for a team
  """
  @spec get_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [Member.t()]
  def get_by_team_id(team_id, repo \\ Read) do
    from(t in Member,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id
    )
    |> repo.all()
  end

  @doc """
  Return a single active member by a unique phone number
  """
  @spec get_by_phone(phone_number :: String.t(), repo :: Ecto.Repo.t()) :: Member.t() | nil
  def get_by_phone(phone_number, repo \\ Read) do
    from(t in Member,
      where: is_nil(t.deleted_at),
      where: t.phone_number == ^phone_number,
      limit: 1
    )
    |> repo.one()
  end

  @doc """
  Creates a new member
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Member{}
    |> Member.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Upsert a member
  """
  @spec upsert(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def upsert(params, repo \\ Write) do
    query =
      from(m in Member,
        where: m.phone_number == ^params.phone_number,
        where: m.team_id == ^params.team_id
      )

    case repo.one(query) do
      nil ->
        create(params)

      member ->
        update(member, params)
    end
  end

  @doc """
  Updates an existing member
  """
  @spec update(member :: Member.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def update(%Member{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Member.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a member. This is a logical delete
  """
  @spec delete(member :: Member.t(), repo :: Ecto.Repo.t()) ::
          {:ok, Member.t()} | {:error, :no_record_found}
  def delete(%Member{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %Member{} = member ->
        update(member, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end

  def count_all_new_member(to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query = from(m in Member,
    join: cm in ConversationMessage, on: cm.phone_number == m.phone_number,
    where: is_nil(m.deleted_at))

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to),
           do: query,
           else: from([m, cm] in query, where: m.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from),
           do: query,
           else: from([m,cm] in query, where: m.inserted_at >= ^from)

      _, query ->
        query
    end)

    query = from([m, cm] in query,
     group_by: [m.id],
     having: count(cm.id) < 5,
      select: count(m.id, :distinct)
    )
     repo.all(query) |> Enum.count()
  end

  def count_all_new_member_by(to, from, loc_ids, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query = from(m in Member,
      join: c in Data.Schema.Conversation, on: c.original_number == m.phone_number,
      join: cm in ConversationMessage, on: cm.conversation_id == c.id,
      where: c.location_id in ^loc_ids,
      where: cm.phone_number == m.phone_number,
      where: is_nil(m.deleted_at))

    query =
      Enum.reduce(%{to: to, from: from}, query, fn
        {:to, to}, query ->
          if is_nil(to),
             do: query,
             else: from([m,c, cm] in query, where: cm.inserted_at <= ^to)

        {:from, from}, query ->
          if is_nil(from),
             do: query,
             else: from([m,c,cm] in query, where: cm.inserted_at >= ^from)

        _, query ->
          query
      end)

    query = from([m,c, cm] in query,
#      group_by: [m.id],
#      having: count(cm.id) < 5,
#      select: count(m.id)
        group_by: c.id,
        select: %{id: c.id, count: count(cm.id)}
    )
    repo.all(query) |> Enum.count(&(&1.count < 5))
  end


  def count_active_users(repo \\ Read)do
    from(m in Member,
    join: cm in ConversationMessage, on: cm.phone_number == m.phone_number,
    where: cm.inserted_at > ago(5, "minute"),
    where: is_nil(m.deleted_at),
    select: count(m, :distinct)
    )
    |> repo.one()
  end

  def count_active_users_by(loc_ids, repo \\ Read)do
    from(m in Member,
      join: c in Data.Schema.Conversation, on: c.original_number == m.phone_number,
      join: cm in ConversationMessage, on: cm.conversation_id == c.id,
      where: c.location_id in ^loc_ids,
      where: cm.phone_number == m.phone_number,
#      where: is_nil(m.deleted_at)),
      where: cm.inserted_at > ago(5, "minute"),
      where: is_nil(m.deleted_at),
      select: count(m, :distinct)
    )
    |> repo.one()
  end
end
