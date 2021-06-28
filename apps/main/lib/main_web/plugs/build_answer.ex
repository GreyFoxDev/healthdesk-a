defmodule MainWeb.Plug.BuildAnswer do
  @moduledoc """
  This plug matches the intent for a response.
  """

  require Logger

  import Plug.Conn

  alias MainWeb.{Notify}
  alias Data.Location
  alias Data.Conversations, as: C

  alias Main.Service.Appointment
  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  @doc """
  If the intent is 'unknown' then the super admin for the location needs to be notified that there is a new
  message in the queue.
  """
  def call(%{assigns: %{convo: _id,  status: "open", intent: nil} = _assigns} = conn, _opts) do
    conn
    |> assign(:status, "open")
  end
  def call(%{assigns: %{convo: id,  status: "open", intent: {:unknown, []}=intent, location: location} = assigns} = conn, _opts) do
    convo = C.get(id)
    appointment = convo.appointment
    reply = Appointment.get_next_reply(id,intent, location)
    if appointment do
      conn
      |> assign(:response, reply)
      |> assign(:appointment, true)

    else
      pending_message_count = (ConCache.get(:session_cache, id) || 0)
      :ok = notify_admin_user(assigns)
      :ok = ConCache.put(:session_cache, id, pending_message_count + 1)

      conn
      |> assign(:status, "pending")
      |> assign(:response, reply)
    end
  end

  @doc """
  If there is a known intent then get the corresponding response.
  """
  def call(%{assigns: %{convo: _id, status: "open", intent: {:subscribe, []}=_intent, location: _location}} = conn, _opts) do
      conn
      |> assign(:status, "closed")
  end
  def call(%{assigns: %{convo: _id, status: "open", _intent: {:unsubscribe, []}=_intent, location: _location}} = conn, _opts) do
      conn
      |> assign(:status, "closed")
  end

  def call(%{assigns: %{convo: id, status: "open", intent: intent, location: location}} = conn, _opts) do
    response = Appointment.get_next_reply(id,intent, location)

    location = Location.get_by_phone(location)
    IO.inspect("##########response#########")
    IO.inspect(response)
    IO.inspect("###################")

    if String.contains?(response,location.default_message)do
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

  def call(conn, _opts), do: conn


  defp notify_admin_user(%{message: message, member: member, convo: convo, location: location}) do
    message = """
    Message From: #{member}\n
    #{message}
    """

    :ok = Notify.send_to_admin(convo, message, location)

  end
end
