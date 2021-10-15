defmodule MainWeb.Plug.BuildAnswer do
  @moduledoc """
  This plug matches the intent for a response.
  """

  require Logger

  import Plug.Conn

  alias MainWeb.{Notify}
  alias Data.Location
  alias Data.Conversations, as: C
  alias Data.{Conversations, ConversationMessages, TeamMember, Location}

  alias Main.Service.Appointment
  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  @doc """
  If the intent is 'unknown' then the super admin for the location needs to be notified that there is a new
  message in the queue.
  """
  def call(%{assigns: %{convo: id,  status: "open",message: message, member: member, intent: nil,location: location} = assigns} = conn, _opts) do
    if (assigns[:team_member_id] == nil) do
      notify_admin_user(conn.assigns)
    else
      convo = C.get(id)
      if (assigns[:team_member_id] == nil && convo.channel_type != "App") do
        notify_admin_user(conn.assigns)
      else
        if (convo.channel_type != "App" ) do
          team_member =
            team_member = TeamMember.get(%{role: "admin"}, assigns[:team_member_id])
          location = Location.get_by_phone(location)
          case convo.member do
            nil ->  Notify.send_to_teammate(id, message, location, team_member, build_member(conn))
            member -> Notify.send_to_teammate(id, message, location, team_member, member)

          end
        end
      end
    end
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

  def call(%{assigns: %{convo: id,message: message, member: member, location: location} = assigns} = conn, _opts)do
    convo = C.get(id)
    if (assigns[:team_member_id] == nil && convo.channel_type != "App") do
      notify_admin_user(conn.assigns)
    else

      if (convo.channel_type != "App" ) do
        team_member =
          team_member = TeamMember.get(%{role: "admin"}, assigns[:team_member_id])
        location = Location.get_by_phone(location)
        case convo.member do
          nil ->  Notify.send_to_teammate(id, message, location, team_member, build_member(conn))
          member -> Notify.send_to_teammate(id, message, location, team_member, member)

        end
      end
    end
    conn
  end


  defp notify_admin_user(%{message: message, member: member, convo: convo_id, location: location}) do
        Notify.send_to_admin(convo_id, message, location, "location-admin")

  end
  defp build_member(%{assigns: %{memberName: memberName, phoneNumber: phoneNumber, email: email}} = conn) do
    name=String.split(memberName, " ", parts: 2)
    name = if(length(name)==1) do
      %{first_name: List.first(name), last_name: ""}
    else
      %{first_name: List.first(name), last_name: List.last(name)}
    end
    Map.merge(name, %{email: email, phone_number: phoneNumber})

  end
end
