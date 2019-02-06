defmodule MainWeb.Plug.CloseConversation do
  @moduledoc """

  """

  require Logger

  import Plug.Conn

  alias Data.Commands.Conversations, as: C
  alias Data.Commands.ConversationMessages, as: CM

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, opts)

  def call(%{assigns: %{opt_in: false}} = conn, _opts), do: conn

  def call(%{assigns: %{convo: id, location: location, intent: :unknown_intent}} = conn, _opts) do
    CM.write_new_message(id, location, conn.assigns[:response])

    conn
  end

  def call(%{assigns: %{convo: id, location: location}} = conn, _opts) do
    CM.write_new_message(id, location, conn.assigns[:response])
    C.close(id)

    conn
  end

  def call(conn, _opts), do: conn

end
