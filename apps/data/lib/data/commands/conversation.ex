defmodule Data.Commands.Conversations do
  @moduledoc """
  Commands for Conversations
  """

  use Data.Commands, schema: Conversation

  alias Data.Commands.Location
  alias Data.Schema.Conversation

  @open %{"status" => "open"}
  @closed %{"status" => "closed"}
  @pending %{"status" => "pending"}

  @doc """
  Gets all the conversations for a location using the location id
  """
  @spec all(location_id :: binary) :: list()
  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)

  @doc """
  Finds a conversation by member's phone number
  """
  @spec get_by_phone(phone_number :: binary, location_id :: binary) :: Conversation.t() | nil
  def get_by_phone(phone_number, location_id),
    do: {:ok, Read.get_by_phone(phone_number, location_id)}

  @doc """
  Retrieves a conversation from the database. If one isn't found then it will create one
  and return it. Conversations are unique to locations.
  """
  @spec find_or_start_conversation({member :: binary, location :: binary}) :: Conversation.t() | nil
  def find_or_start_conversation({member, location}) do

    with %Data.Schema.Location{} = location <- Location.get_by_phone(location),
          {:ok, nil} <- get_by_phone(member, location.id) do
      convo =
      {member, location.id}
      |> new_params()
      |> write()
    else
      {:ok, %Data.Schema.Conversation{status: "closed"} = conversation} ->
        write(conversation, @open)

      {:ok, %Data.Schema.Conversation{}} = response ->
        response
    end
  end

  @doc """
  Sets the status to pending for an existing conversation
  """
  @spec pending(id :: binary) :: {:ok, Conversation.t()} | {:error, String.t()}
  def pending(id) do
    with %Data.Schema.Conversation{id: id} = convo <- get(id),
         {:ok, %Data.Schema.Conversation{id: id} = convo} <- write(convo, @pending) do
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
    with %Data.Schema.Conversation{id: id} = convo <- get(id),
         {:ok, %Data.Schema.Conversation{id: id} = convo} <- write(convo, @closed) do
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
