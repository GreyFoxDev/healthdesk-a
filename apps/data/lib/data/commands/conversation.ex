defmodule Data.Commands.Conversations do
  @moduledoc """
  Commands for Conversations
  """

  use Data.Commands, schema: Conversation

  alias Data.Commands.Location
  alias Data.Schema.Conversation

  @closed %{"status" => "closed"}

  @doc """
  Gets all the conversations for a location using the location id
  """
  @spec all(location_id :: binary) :: list()
  def all(location_id),
    do: Command.execute_task_with_results(fn -> Read.all(location_id) end)

  @doc """
  Finds a conversation by member's phone number
  """
  @spec get_by_phone(phone_number :: binary) :: Conversation.t() | nil
  def get_by_phone(phone_number),
    do: {:ok, Read.get_by_phone(phone_number)}

  @doc """
  Retrieves a conversation from the database. If one isn't found then it will create one
  and return it.
  """
  @spec find_or_start_conversation({member :: binary, location :: binary}) ::
          Conversation.t() | nil
  def find_or_start_conversation({member, location}) do
    with {:ok, nil} <- get_by_phone(member),
         %Data.Schema.Location{} = location <- Location.get_by_phone(location) do
      convo =
        {member, location.id}
        |> new_params()
        |> write()

      {:ok, convo}
    else
      {:ok, %Data.Schema.Conversation{} = conversation} ->
        {:ok, write(conversation, %{"status" => "open"})}
    end
  end

  @doc """
  Closes an existing conversation
  """
  @spec close(id :: binary) :: {:ok, Conversation.t()} | {:error, String.t()}
  def close(id) do
    IO.inspect "HERE****"
    with %Data.Schema.Conversation{id: id} = convo <- get(id),
         %Data.Schema.Conversation{id: id} = convo <- write(convo, @closed) do
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
