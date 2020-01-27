defmodule Data.Conversations do
  @moduledoc """
  This is the Conversation API for the data layer
  """
  alias Data.Query.Conversation, as: Query
  alias Data.Schema.Conversation, as: Schema
  alias Data.Schema.Location

  @roles [
    "admin",
    "teammate",
    "location-admin",
    "team-admin"
  ]

  @open %{"status" => "open"}
  @closed %{"status" => "closed"}
  @pending %{"status" => "pending"}

  defdelegate create(params), to: Query
  defdelegate get_by_phone(phone_number, location_id), to: Query

  @doc """
  Get changesets for conversations.
  """
  def get_changeset(),
    do: Data.Schema.Conversation.changeset(%Data.Schema.Conversation{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Conversations.get()
      |> Data.Schema.Conversation.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles,
    do: Query.get_by_location_id(location_id)

  def all(_, _), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Conversations.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id)

  def get(_, _), do: {:error, :invalid_permissions}

  def update(%{"id" => id} = params) do
    id
    |> Query.get()
    |> Query.update(params)
  end

  @doc """
  Retrieves a conversation from the database. If one isn't found then it will create one
  and return it. Conversations are unique to locations.
  """
  @spec find_or_start_conversation({member :: binary, location :: binary}) ::
          Conversation.t() | nil
  def find_or_start_conversation({member, location}) do
    with %Location{} = location <- Data.Query.Location.get_by_phone(location),
         {:ok, nil} <- get_by_phone(member, location.id) do
      convo =
        {member, location.id}
        |> new_params()
        |> create()
    else
      {:ok, %Schema{status: "closed"} = conversation} ->
        Query.update(conversation, @open)

      {:ok, %Schema{}} = response ->
        response
    end
  end

  @doc """
  Sets the status to pending for an existing conversation
  """
  @spec pending(id :: binary) :: {:ok, Conversation.t()} | {:error, String.t()}
  def pending(id) do
    with %Schema{id: id} = convo <- Query.get(id),
         {:ok, %Schema{id: id} = convo} <- Query.update(convo, @pending) do
      {:ok, convo}
    else
      _ ->
        {:error, "Unable to change conversation status to pending."}
    end
  end

  @doc """
  Closes an existing conversation
  """
  @spec close(id :: binary) :: {:ok, Conversation.t()} | {:error, String.t()}
  def close(id) do
    with %Schema{id: id} = convo <- Query.get(id),
         {:ok, %Schema{id: id} = convo} <- Query.update(convo, @closed) do
      {:ok, convo}
    else
      _ ->
        {:error, "Unable to close conversation."}
    end
  end

  defp new_params({member, location_id}) do
    %{
      "location_id" => location_id,
      "original_number" => member,
      "status" => "open",
      "started_at" => DateTime.utc_now()
    }
  end
end
