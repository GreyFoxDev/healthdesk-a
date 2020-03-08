defmodule MainWeb.Plug.CloseConversation do
  @moduledoc """
  Module for the close conversation plug
  """
  import Plug.Conn

  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, opts)

  @doc """
  If the conversation is in a pending state, or the member has not opted in,
  then no need to do anything. Just return the connection.
  """
  def call(%{assigns: %{convo: id, location: location, status: "pending"}} = conn, _opts) do
    convo = C.get(id)
    pending_message_count = (ConCache.get(:session_cache, id) || 0)

    if pending_message_count <= 1 do
      CM.create(%{
            "conversation_id" => id,
            "phone_number" => location,
            "message" => conn.assigns[:response],
            "sent_at" => DateTime.utc_now()})
    end

    C.pending(id)
    conn
  end

  @doc """
  If the intent isn't found then set the conversation status to pending while
  an admin addresses the member.
  """
  def call(%{assigns: %{convo: id, intent: {:unknown, []}}} = conn, _opts) do
    C.pending(id)
    conn
  end

  def call(%{assigns: %{convo: id, intent: :unknown_intent}} = conn, _opts) do
    C.pending(id)
    conn
  end

  @doc """
  If the question has been answered then close the conversation
  """
  def call(%{assigns: %{convo: id, location: location} = assigns} = conn, _opts) do
    CM.create(%{
          "conversation_id" => id,
          "phone_number" => location,
          "message" => conn.assigns[:response],
          "sent_at" => DateTime.utc_now()})

    convo = C.get(id)
    location = Data.Location.get(convo.location_id)
    dispositions = Data.Disposition.get_by_team_id(%{role: "system"}, location.team_id)

    if conn.assigns[:response] != "No sweat!" do
      disposition = Enum.find(dispositions, &(&1.disposition_name == "Automated"))

      Data.ConversationDisposition.create(%{"conversation_id" => id, "disposition_id" => disposition.id})

      %{"conversation_id" => id,
        "phone_number" => location.phone_number,
        "message" => "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.add(DateTime.utc_now(), 3)}
      |> CM.create()
    else
      %{"conversation_id" => id,
        "phone_number" => location.phone_number,
        "message" => "CLOSED: Closed by System",
        "sent_at" => DateTime.add(DateTime.utc_now(), 3)}
      |> CM.create()
    end

    C.close(id)

    _ = ConCache.delete(:session_cache, id)

    conn
  end

  def call(conn, _opts), do: conn

end
