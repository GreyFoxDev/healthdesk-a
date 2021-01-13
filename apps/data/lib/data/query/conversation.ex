defmodule Data.Query.Conversation do
  @moduledoc """
  Module for the Conversation queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Conversation,ConversationMessage, Member}
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @doc """
  Returns a conversation by id
  """
  @spec get(id :: binary(), check :: boolean(), repo :: Ecto.Repo.t()) :: Conversation.t() | nil
  def get(id, preload_f\\true, repo \\ Read)
  def get(id, false, repo)  do
    from(c in Conversation,
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.id == ^id,
      preload: [:location, team_member: [:user]],
      select: %{c | member: member}
    )
    |> repo.one()
  end
  def get(id,true, repo) do
    from(c in Conversation,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.id == ^id,
      order_by: [desc: m.sent_at],
      preload: [:location, conversation_messages: m, team_member: [ :user]],
      select: %{c | member: member}
    )
    |> repo.one()
  end

  @doc """
  Update Conversations
  """
  @spec update_conversation(repo :: Ecto.Repo.t()) :: [Conversation.t()]
  def update_conversation(repo \\ Read) do
    time = DateTime.add(DateTime.utc_now(), -24 * 3600)
    query = from(
              c in Conversation,
              where: c.appointment == true and c.updated_at > ^time,
              select: c.appointment
            )
            |> repo.update_all(
                 set: [
                   appointment: false
                 ]
               )
  end

  @doc """
  Return a list of conversations for a location
  """
  @spec get_by_status(location_id :: [binary()], status :: [binary()], repo :: Ecto.Repo.t()) :: [Conversation.t()]
  def get_by_status(location_id, status, repo \\ Read) when is_list(status) do
    time = DateTime.add(DateTime.utc_now(), -1296000, :seconds)

    from(c in Conversation,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id in ^location_id,
      where: c.status in ^status,
      where: m.sent_at >=  ^time ,

      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user], location: []],
      select: %{c | member: member}
    )
    |> repo.all()
  end
  @spec get_by_location_ids(location_id :: [binary()], repo :: Ecto.Repo.t()) :: [Conversation.t()]
  def get_by_location_ids(location_id, repo \\ Read) do
    from(c in Conversation,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id in ^location_id,
      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user]],
      select: %{c | member: member}
    )
    |> repo.all()
  end
  @spec get_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [Conversation.t()]
  def get_by_location_id(location_id, repo \\ Read) do
    from(c in Conversation,
      join: m in assoc(c, :conversation_messages),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id == ^location_id,
      # most recent first
      order_by: [desc: m.sent_at],
      preload: [conversation_messages: m, team_member: [:user]],
      select: %{c | member: member}
    )
    |> repo.all()
  end

  @doc """
  Return a single conversation by a unique phone number and location id
  """
  @spec get_by_phone(phone_number :: String.t(), repo :: Ecto.Repo.t()) :: Location.t() | nil
  def get_by_phone(phone_number, location_id, repo \\ Read) do
    from(c in Conversation,
      where: c.original_number == ^phone_number,
      where: c.location_id == ^location_id
    )
    |> repo.one()
  end

  @doc """
  Creates a new conversation
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Conversation.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Conversation{}
    |> Conversation.changeset(params)
    |> case do
         %Ecto.Changeset{valid?: true} = changeset ->
           repo.insert(changeset)

         changeset ->
           {:error, changeset}
       end
  end

  @doc """
  Updates an existing conversation
  """
  @spec update(conversation :: Conversation.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Conversation.t()} | {:error, Ecto.Changeset.t()}
  def update(%Conversation{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Conversation.changeset(params)
    |> case do
         %Ecto.Changeset{valid?: true} = changeset ->
           repo.update(changeset)

         changeset ->
           {:error, changeset}
       end
  end
end
