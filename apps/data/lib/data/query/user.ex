defmodule Data.Query.User do
  @moduledoc """
  Module for the User queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.User
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Return a list of active users
  """
  @spec all(repo :: Ecto.Repo.t()) :: [User.t()]
  def all(repo \\ Read) do
    from(t in User,
      where: is_nil(t.deleted_at)
    )
    |> repo.all()
  end

  @doc """
  Returns a user by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: User.t() | nil
  def get(id, repo \\ Read) do
    from(u in User,
      left_join: t in assoc(u, :team_member),
      where: is_nil(u.deleted_at),
      where: u.id == ^id,
      preload: [team_member: {t, [:location, team_member_locations: [location: :conversations]]}]
    )
    |> repo.one()
  end

  @doc """
  Returns a list of Super Admins
  """
  @spec get_admin_emails(repo :: Ecto.Repo.t()) :: User.t() | nil
  def get_admin_emails(repo \\ Read) do
    from(u in User,
      where: is_nil(u.deleted_at),
      where: u.role == "admin",
      select: u.email
    )
    |> repo.all()
  end

  @doc """
  Returns a user phone no by id
  """
  @spec get_phone_by_id(id :: binary(), repo :: Ecto.Repo.t()) :: User.t() | nil
  def get_phone_by_id(id, repo \\ Read) do
    from(u in User,
      where: is_nil(u.deleted_at),
      where: u.id == ^id,
      select: u.phone_number
    )
    |> repo.one()
  end

  @doc """
  Return a single active user by a unique phone number
  """
  @spec get_by_phone(phone_number :: String.t(), repo :: Ecto.Repo.t()) :: User.t() | nil
  def get_by_phone(phone_number, repo \\ Read) do
    from(u in User,
      left_join: t in assoc(u, :team_member),
      where: is_nil(u.deleted_at),
      where: u.phone_number == ^phone_number,
      preload: [team_member: {t, team_member_locations: :location}]
    )
    |> repo.one()
  end

  @doc """
  Creates a new user
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %User{}
    |> User.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing user
  """
  @spec update(user :: User.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update(%User{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> User.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a user. This is a logical delete
  """
  @spec delete(user :: User.t(), repo :: Ecto.Repo.t()) ::
          {:ok, User.t()} | {:error, :no_record_found}
  def delete(%User{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %User{} = user ->
        update(user, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
