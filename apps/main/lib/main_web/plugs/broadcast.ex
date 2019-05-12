defmodule MainWeb.Plug.Broadcast do
  @moduledoc false

  import Plug.Conn

  alias Data.Commands.Member, as: MCommand
  alias Data.Commands.Location, as: LCommand

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, opts)

  def call(%{assigns: %{convo: convo, member: member, location: location, message: message} = assigns} = conn, _opts) do
    with {:ok, nil} <- MCommand.get_by_phone(member) do
      MainWeb.Endpoint.broadcast("convo:#{convo}", "broadcast", %{message: message, phone_number: member})
    else
      {:ok, member} ->
        name = Enum.join([member.first_name, member.last_name], " ")
        MainWeb.Endpoint.broadcast("convo:#{convo}", "broadcast", %{message: message, name: name})
    end

    case LCommand.get_by_phone(location) do
      nil -> nil
      location ->
        alert_info = Map.merge(assigns, %{location: location, member: member})
        MainWeb.Endpoint.broadcast("alert:admin", "broadcast", alert_info)
        MainWeb.Endpoint.broadcast("alert:#{location.phone_number}", "broadcast", alert_info)
    end
    conn
  end

end
