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

  def handle_in("shout", %{"message" =>  message}, socket) do
    location = get_location(socket.assigns[:key])

    response = %Plug.Conn{
      assigns: %{
        opt_in: true,
        message: message,
        member: socket.assigns[:user],
        location: location.phone_number
      }
    }
    |> P.OpenConversation.call([])
    |> P.AskWit.call([])
    |> P.BuildAnswer.call([])
    |> P.CloseConversation.call([])

    if response.assigns[:status] == "pending" do
      message = "Sorry I can't help with that but please call #{location.phone_number} for assistance?"
      broadcast socket, "shout", %{message: message, from: "Bot"}
    else
      broadcast socket, "shout", %{message: response.assigns[:response], from: "Bot"}
    end

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    broadcast socket, "shout", %{message: "Greetings! How can I help?", from: "Bot"}
    {:noreply, socket}
  end

  def handle_in(event, payload, socket) do
    Logger.warn("INVALID EVENT: #{IO.inspect(event)} with payload #{IO.inspect(payload)}")
    {:noreply, socket}
  end

  defp authorized?(key) do
    get_location(key) != nil
  end

  defp get_location(key) do
    Location.get_by_api_key(key)
  end
end
