defmodule MainWeb.Plug.BuildAnswer do
  @moduledoc """
  This plug matches the intent for a response.
  """

  require Logger

  import Plug.Conn

  alias MainWeb.{Intents, Notify}
  alias Data.Location

  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  @doc """
  If the intent is 'unknown' then the super admin for the location needs to be notified that there is a new
  message in the queue.
  """
  def call(%{assigns: %{convo: id, opt_in: true, status: "open", intent: {:unknown, []}} = assigns} = conn, _opts) do
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
  def call(%{assigns: %{opt_in: true, status: "open", intent: intent, location: location}} = conn, _opts) do
    response = Intents.get(intent, location)

    location = Location.get_by_phone(location)

    if response == location.default_message do
      :ok = notify_admin_user(conn.assigns)

      conn
      |> assign(:status, "pending")
      |> assign(:response, response)
    else
      assign(conn, :response, response)
    end
  end

  def call(conn, _opts), do: conn

  defp notify_admin_user(%{message: message, member: member, convo: convo, location: location}) do
    message = """
    Message From: #{member}\n
    #{message}
    """

    :ok = Notify.send_to_admin(convo, message, location)

  end
end
