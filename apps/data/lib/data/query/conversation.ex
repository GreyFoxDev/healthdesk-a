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
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Conversation.t() | nil
  def get(id, repo \\ Read) do
    from(c in Conversation,
      join: m in assoc(c, :conversation_messages),
      left_join: t in assoc(c, :team_member),
      left_join: u in assoc(t, :user),
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.id == ^id,
      order_by: m.sent_at,
      limit: 1,
      preload: [:location, conversation_messages: m, team_member: {t, user: u}],
      select: %{c | member: member}
    )
    |> repo.one()
  end

  @doc """
  Return a list of conversations for a location
  """
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
  @spec get_open_by_location_id(location_id :: binary(), limit :: integer(), offset :: integer(), repo :: Ecto.Repo.t()) :: [Conversation.t()]
  def get_open_by_location_id(location_id,limit , offset , repo \\ Read) do
    comment_order_query = from(c in Comment, order_by: c.inserted_at, preload: [:user])

    from(c in Conversation,
      join:  m in ConversationMessage,
      on: m.conversation_id == c.id,
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id == ^location_id,
      where: c.status in ["open","pending"],
      preload: [conversation_messages: m, team_member: [:user]],
      order_by: [desc: m.sent_at,],
      select: %{c | member: member},
      limit: ^limit,
      offset: ^offset
    )
    |> repo.all() |> repo.preload([:conversation_messages, team_member: [:user]])

  end
  @spec get_closed_by_location_id(location_id :: binary(), limit :: integer(), offset :: integer(), repo :: Ecto.Repo.t()) :: [Conversation.t()]
  def get_closed_by_location_id(location_id,limit , offset , repo \\ Read) do
    from(c in Conversation,
      inner_join:  m in ConversationMessage,
      on: m.conversation_id == c.id,
      left_join: member in Member,
      on: c.original_number == member.phone_number,
      where: c.location_id == ^location_id,
      where: c.status in ["closed"],
      order_by: [desc: m.sent_at,],
      select: %{c | member: member},
      limit: ^limit,
      offset: ^offset
    )
    |> repo.all() |> repo.preload([:conversation_messages, team_member: [:user]])
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
