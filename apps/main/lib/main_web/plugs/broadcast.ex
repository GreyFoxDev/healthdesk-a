defmodule MainWeb.Plug.Broadcast do
  @moduledoc false



  alias Data.{Member, Location}
  alias Data.Schema.Member, as: MemberSchema

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, opts)

  def call(%{assigns: %{convo: convo, member: member, location: location, message: message} = assigns} = conn, _opts) do
    with nil <- Member.get_by_phone(member) do
      MainWeb.Endpoint.broadcast("convo:#{convo}", "broadcast", %{message: message, phone_number: member})
    else
      %MemberSchema{} = member ->
      if member.first_name && member.last_name do
        name = Enum.join([member.first_name, member.last_name], " ")
        MainWeb.Endpoint.broadcast("convo:#{convo}", "broadcast", %{message: message, name: name, phone_number: member.phone_number})
      else
        MainWeb.Endpoint.broadcast("convo:#{convo}", "broadcast", %{message: message, phone_number: member.phone_number})
      end
    end

    case Location.get_by_phone(location) do
      nil -> nil
      location ->
        alert_info = Map.merge(assigns, %{location: location, member: member})
        Main.LiveUpdates.notify_live_view({location.id, :updated_open})
        MainWeb.Endpoint.broadcast("alert:admin", "broadcast", alert_info)
        MainWeb.Endpoint.broadcast("alert:#{location.phone_number}", "broadcast", alert_info)

    end
    conn
  end
  def call(conn, _opts), do: conn

end
