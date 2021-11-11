defmodule Data.Query.Location do
  @moduledoc """
  Module for the Location queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Location,Conversation, ConversationMessage}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Return a list of active locations
  """
  @spec all(repo :: Ecto.Repo.t()) :: [Location.t()]
  def all(repo \\ Read) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      preload: [:team]
    )
    |> repo.all()
    |> Enum.filter(&(&1.team.deleted_at == nil))
  end

  @doc """
  Returns a location by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get(id, repo \\ Read) do
    from(t in Location, where: is_nil(t.deleted_at), where: t.id == ^id)
    |> repo.one()
  end



  @doc """
  Returns a locations by ids
  """
  @spec get_locations_by_ids(id :: binary(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get_locations_by_ids(id, repo \\ Read) do
    from(t in Location, where: is_nil(t.deleted_at), where: t.id in ^id)
    |> repo.all()
  end

  @doc """
  Returns a Automation Limit by id
  """
  @spec get_automation_limit(id :: binary(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get_automation_limit(id, repo \\ Read) do
    from(l in Location,
      where: is_nil(l.deleted_at),
      where: l.id == ^id,
      select: l.automation_limit
    )
    |> repo.one()
  end

  @doc """
  Return a single active location by a unique phone number
  """
  def get_by_phone(phone_number, repo \\ Read) when is_binary(phone_number) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.phone_number == ^phone_number,
      limit: 1,
      preload: [:team]
    )
    |> repo.one()
  end

  def get_by_phone(phone_number, repo) when is_list(phone_number) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.phone_number in ^phone_number,
      limit: 1,
      preload: [:team]
    )
    |> repo.all()
    |> List.first()
  end

  def get_by_phone(phone_number, repo) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.phone_number == ^phone_number,
      limit: 1,
      preload: [:team]
    )
    |> repo.one()
  end

  @doc """
  Return a list of active locations for a team
  """
  @spec get_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [Location.t()]
  def get_by_team_id(team_id, repo \\ Read) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id,
      order_by: t.location_name,
      preload: [:team]
    )
    |> repo.all()
  end

  @doc """
  Return a list of active location ids for a team
  """
  @spec get_location_ids_by_team_id(team_id :: binary(), repo :: Ecto.Repo.t()) :: [Location.t()]
  def get_location_ids_by_team_id(team_id, repo \\ Read) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.team_id == ^team_id,
      select: t.id
    )
    |> repo.all()
  end

  @doc """
  Return a single active location by a unique api key
  """
  @spec get_by_api_key(api_key :: binary(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get_by_api_key(key, repo \\ Read) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.api_key == ^key,
      limit: 1,
      preload: [:team]
    )
    |> repo.one()
  end

  @doc """
  Return a single active location by a unique page_id
  """
  @spec get_by_page_id(page_id :: binary(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get_by_page_id(page_id, repo \\ Read) do
    location = from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.facebook_page_id == ^page_id,
      limit: 1,
      preload: [:team]
    )
    |> repo.one()
    location || false
  end

  @doc """
  Return a single active location by a unique messenger id
  """
  @spec get_by_messenger_id(messenger_id :: String.t(), repo :: Ecto.Repo.t()) ::
          Location.t() | nil
  def get_by_messenger_id(messenger_id, repo \\ Read) do
    from(t in Location,
      where: is_nil(t.deleted_at),
      where: t.messenger_id == ^messenger_id,
      limit: 1,
      preload: [:team]
    )
    |> repo.one()
  end

  @doc """
  Creates a new location
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Location.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Location{}
    |> Location.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing location
  """
  @spec update(location :: Location.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Location.t()} | {:error, Ecto.Changeset.t()}
  def update(%Location{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Location.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a location. This is a logical delete
  """
  @spec delete(location :: Location.t(), repo :: Ecto.Repo.t()) ::
          {:ok, Location.t()} | {:error, :no_record_found}
  def delete(%Location{id: id}, repo \\ Write) do
    id
    |> get(repo)
    |> case do
      %Location{} = location ->
        update(location, %{deleted_at: DateTime.utc_now()}, repo)

      nil ->
        {:error, :no_record_found}
    end
  end
end
