defmodule MainWeb.Plug.CloseConversation do
  @moduledoc """

  """

  require Logger

  import Plug.Conn

  alias Data.Commands.Conversations, as: C
  alias Data.Commands.ConversationMessages, as: CM

  @default "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day!"

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

    count = convo.conversation_messages
    |> Enum.filter(fn m -> m.message == @default end)
    |> Enum.count()

    if count < 2 && conn.assigns[:response] == @default do
      CM.write_new_message(id, location, conn.assigns[:response])
    end

    C.pending(id)
    conn
  end
  def call(%{assigns: %{convo: id, location: location, opt_in: false}} = conn, _opts) do
    CM.write_new_message(id, location, conn.assigns[:response])
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
    CM.write_new_message(id, location, conn.assigns[:response])
    C.close(id)

    conn
  end

  def call(conn, _opts), do: conn

end
