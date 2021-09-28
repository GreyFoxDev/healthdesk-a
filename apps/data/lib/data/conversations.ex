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
  defdelegate count_active_convo(location_id, status, user_id, check), to: Query
  defdelegate count_assigned_convo(location_id, status, user_id), to: Query
  defdelegate count_closed_convo(location_id, status), to: Query
  defdelegate get_by_phone(phone_number, location_id), to: Query
  defdelegate get(conversation_id), to: Query
  defdelegate update_conversation(), to: Query

  @doc """
  Get changesets for conversations.
  """
  def get_changeset(),
    do: Data.Schema.Conversation.changeset(%Data.Schema.Conversation{})

  def get_changeset(id, %{role: role}) when role in @roles do
    changeset =
      id
      |> Query.get()
      |> Schema.changeset()

    {:ok, changeset}
  end

  def all(%{role: role}, location_id) when role in @roles and is_list(location_id) do
    Query.get_by_location_ids(location_id)
  end

  def all(%{role: role}, location_id) when role in @roles do
    Query.get_by_location_id(location_id)
  end

  def all(%{role: role}, location_id, status) when role in @roles and is_list(location_id) do
    Query.get_by_status(location_id, status)
  end

  #  def filter(%{role: role}, location_id, status, search_String) when role in @roles and is_list(location_id) do
  #    Query.get_by_status(location_id, status,search_String)
  #  end

  def filter(%{role: role}, location_id, status, user_id, check, search_string)
      when role in @roles and is_list(location_id) do
    Query.get_filtered_conversations(location_id, status, user_id, check, search_string)
  end

  def filter(%{role: role}, location_id, status, user_id, search_string)
      when role in @roles and is_list(location_id) do
    Query.get_filtered_conversations(location_id, status, user_id, search_string)
  end

  def filter(%{role: role}, location_id, status, search_string)
      when role in @roles and is_list(location_id) do
    Query.get_filtered_conversations(location_id, status, search_string)
  end

  def all(%{role: role}, location_id, status, offset, limit, user_id, check)
      when role in @roles and is_list(location_id) do
    Query.get_limited_conversations(location_id, status, offset, limit, user_id, check)
  end

  def all(%{role: role}, location_id, status, offset, limit, user_id)
      when role in @roles and is_list(location_id) do
    Query.get_limited_conversations(location_id, status, offset, limit, user_id)
  end

  def all(%{role: role}, location_id, status, offset, limit)
      when role in @roles and is_list(location_id) do
    Query.get_limited_conversations(location_id, status, offset, limit)
  end

  def all_count(%{role: role}, location_id, status)
      when role in @roles and is_list(location_id) do
    Query.get_by_status_count(location_id, status)
  end

  def all(_, _), do: {:error, :invalid_permissions}

  def all_open(%{role: role}, location_id, limit, offset) when role in @roles do
    Query.get_open_by_location_id(location_id, limit, offset)
  end

  def all_closed(%{role: role}, location_id, limit, offset) when role in @roles do
    Query.get_closed_by_location_id(location_id, limit, offset)
  end

  def get(%{role: role}, id) when role in @roles,
    do: Query.get(id, true)

  def get(%{role: role}, id, preload_f) when role in @roles,
    do: Query.get(id, preload_f)

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
         nil <- get_by_phone(member, location.id) do
      {member, location.id}
      |> new_params()
      |> create()
    else
      %Schema{status: "closed"} = conversation ->
        Query.update(conversation, @open)

      %Schema{} = convo ->
        {:ok, convo}

      error ->
        error
    end
  end

  def find_or_start_conversation(member, location, subject) when is_binary(location) do
    with %Location{} = location <- Data.Query.Location.get_by_phone(location),
         nil <- get_by_phone(member, location.id) do
      {member, location.id}
      |> new_params()
      |> Map.merge(%{"subject" => subject})
      |> create()
    else
      %Schema{status: "closed"} = conversation ->
        Query.update(conversation, %{"subject" => subject})

      %Schema{} = convo ->
        Query.update(convo, %{"subject" => subject})

      error ->
        error
    end
  end

  def find_or_start_conversation(member, location, subject) when is_list(location) do
    with %Location{} = location <- Data.Query.Location.get_by_phone(location),
         nil <- get_by_phone(member, location.id) do
      {member, location.id}
      |> new_params()
      |> Map.merge(%{"subject" => subject})
      |> create()
    else
      %Schema{status: "closed"} = conversation ->
        Query.update(conversation, %{"subject" => subject})

      %Schema{} = convo ->
        Query.update(convo, %{"subject" => subject})

      error ->
        error
    end
  end

  def find_or_start_conversation(member, location, subject) when is_binary(location) do
    with %Location{} = location <- Data.Query.Location.get_by_phone(location),
         nil <- get_by_phone(member, location.id) do
      {member, location.id}
      |> new_params()
      |> Map.merge(%{"subject" => subject})
      |> create()
    else
      %Schema{status: "closed"} = conversation ->
        Query.update(conversation, %{"subject" => subject})

      %Schema{} = convo ->
        Query.update(convo, %{"subject" => subject})
    end
  end

  @doc """
  Retrieves a conversation from the database. . Conversations are unique to locations.
  """
  @spec find_conversation({member :: binary, location :: binary}) ::
          Conversation.t() | nil
  def find_conversation({member, location}) do
    with %Location{} = location <- Data.Query.Location.get_by_phone(location),
         nil <- get_by_phone(member, location.id) do
      nil
    else
      %Schema{status: "closed"} = conversation ->
        Query.update(conversation, @open)

      %Schema{} = convo ->
        {:ok, convo}
    end
  end

  @doc """
  Sets the status to pending for an existing conversation
  """
  @spec pending(id :: binary) :: {:ok, Conversation.t()} | {:error, String.t()}
  def pending(id) do
    with %Schema{id: ^id} = convo <- Query.get(id),
         %Schema{id: ^id} = convo <- Query.update(convo, @pending) do
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
    with %Schema{id: ^id} = convo <- Query.get(id),
         {:ok, %Schema{id: ^id} = convo} <- Query.update(convo, @closed) do

      {:ok, convo}
    else
      _ ->
        {:error, "Unable to close conversation."}
    end
  end

  def appointment_open(id) do
    with %Schema{id: ^id} = convo <- Query.get(id),
         %Schema{id: ^id} = convo <-
           Query.update(convo, %{
             "appointment" => true,
             "step" => "1",
             "fallback" => 0,
             "status" => "open"
           }) do
      {:ok, convo}
    else
      _ ->
        {:error, "Unable to close conversation."}
    end
  end

  def appointment_close(id) do
    with %Schema{id: ^id} = convo <- Query.get(id),
         %Schema{id: ^id} = convo <-
           Query.update(convo, %{
             "appointment" => false,
             "step" => "",
             "fallback" => 0,
             "status" => "open"
           }) do
      {:ok, convo}
    else
      _ ->
        {:error, "Unable to close conversation."}
    end
  end

  def appointment_step(id, step, fallback) do
    with %Schema{id: ^id} = convo <- Query.get(id),
         %Schema{id: ^id} = convo <-
           Query.update(convo, %{"step" => step, "fallback" => fallback, "status" => "open"}) do
      {:ok, convo}
    else
      _ ->
        {:error, "Unable to close conversation."}
    end
  end

  def appointment_step(id, step) do
    with %Schema{id: ^id} = convo <- Query.get(id),
         %Schema{id: ^id} = convo <- Query.update(convo, %{"step" => step, "status" => "open"}) do
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
