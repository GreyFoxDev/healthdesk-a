defmodule MainWeb.Plug.BuildAnswer do
  @moduledoc """
  This plug matches the intent for a response.
  """

  require Logger

  import Plug.Conn

  alias MainWeb.{Intents, Notify}
  alias Data.Location

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  @doc """
  If the intent is 'unknown' then the super admin for the location needs to be notified that there is a new
  message in the queue.
  """
  def call(%{assigns: %{convo: id, opt_in: true, status: "open", intent: {:unknown, []}} = assigns} = conn, _opts) do
    IO.inspect assigns, label: "HERE IN BUILD ANSWER????"
    pending_message_count = (ConCache.get(:session_cache, id) || 0)

    :ok = notify_admin_user(assigns)
    :ok = ConCache.put(:session_cache, id, pending_message_count + 1)

    conn
    |> assign(:status, "pending")
    |> assign(:response, Intents.get(:unknown_intent, assigns.location))
  end

  @doc """
  If there is a known intent then get the corresponding response.
  """
  def call(%{assigns: %{convo: id, opt_in: true, status: "open", intent: intent, location: location}} = conn, _opts) do
    response = Intents.get(intent, location)

    location = Location.get_by_phone(location)

    IO.inspect response, label: "RESPONSE"
    IO.inspect location.default_message, label: "DEFAULT MESSAGE"

    if response == location.default_message do
      pending_message_count = (ConCache.get(:session_cache, id) || 0)

      :ok = notify_admin_user(conn.assigns)
      :ok = ConCache.put(:session_cache, id, pending_message_count + 1)

      conn
      |> assign(:status, "pending")
      |> assign(:response, response)
    else
      assign(conn, :response, response)
    end
  end

  def call(conn, _opts), do: IO.inspect(conn, label: "CATCH ALL IN BUILD ANSWER")


  defp notify_admin_user(%{message: message, member: member, convo: convo, location: location}) do
    message = """
    Message From: #{member}\n
    #{message}
    """

    :ok = Notify.send_to_admin(convo, message, location)

  end
end
