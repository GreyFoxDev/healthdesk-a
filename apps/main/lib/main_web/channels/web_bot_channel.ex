defmodule MainWeb.WebBotChannel do
  use MainWeb, :channel

  require Logger

  alias Data.Location
  alias MainWeb.Plug, as: P

  def join("web_bot:" <> id, %{"key" => key}, socket) do
    if authorized?(key) do
      socket = socket
      |> assign(:key, key)
      |> assign(:user, id)

      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("reply", %{"message" => message}, socket) do
    broadcast socket, "reply", %{message: message, from: "Website Bot"}
    {:noreply, socket}
  end

  def handle_in("ping", %{"key" => key}, socket) do
    if authorized?(key) do
      broadcast socket, "ping", %{message: "__pong__"}
    end

    {:noreply, socket}
  end

  def handle_in("shout", %{"message" => message, "key" => key}, socket) do
    if authorized?(key) do
      location = get_location(key)

      response = %Plug.Conn{
        assigns: %{
          opt_in: true,
          message: message,
          member: socket.assigns[:user],
          location: location.phone_number
        }
      }
      |> P.OpenConversation.call([])
      |> P.AskWit.call([],location)
      |> P.BuildAnswer.call([])
      |> P.CloseConversation.call([])
      |> P.Broadcast.call([])

      if response.assigns[:status] != "pending" do
        broadcast socket, "shout", %{message: String.replace(response.assigns[:response], "\n", "<br />"), from: "Website Bot"}
      end
    end

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    location = get_location(socket.assigns[:key])

    if location.web_greeting && location.web_greeting != "" do
      broadcast socket, "shout", %{message: location.web_greeting, from: "Website Bot"}
    else
      broadcast socket, "shout", %{message: "Greetings! How can I help?", from: "Website Bot"}
    end

    {:noreply, socket}
  end

  def handle_in(event, payload, socket) do
    Logger.warn("INVALID EVENT: #{IO.inspect(event)} with payload #{IO.inspect(payload)}")
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.warn("CONNECTION CLOSED: #{inspect reason}")
    :ok
  end

  defp authorized?(key) do
    get_location(key) != nil
  end

  defp get_location(key) do
    Location.get_by_api_key(key)
  end
end
