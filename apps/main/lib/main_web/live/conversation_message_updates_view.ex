defmodule MainWeb.Live.ConversationMessageUpdatesView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.ConversationMessageUpdatesView, as: View
  alias Data.Conversations
  def render(assigns) do
    View.render("index.html", assigns)
  end

  def mount(_params, %{"conversation" => id} = session, socket) do
    MainWeb.Endpoint.subscribe("convo:#{id}")
    socket =
      socket
      |> assign(:session, session)
      |> assign(:messages, [])
    {:ok, socket}
  end

  def handle_info(broadcast = %{topic: << "convo:", id :: binary >>}, socket) do
    conversation =
      socket.assigns.session["user"]
      |> Conversations.get(id)
    case conversation.channel_type do
      "APP" -> {:noreply,socket}
      _ ->  _messages = if socket.assigns, do: (socket.assigns[:messages] || []), else: []

            Main.LiveUpdates.notify_live_view({id, struct( %Data.Schema.ConversationMessage{},broadcast.payload)})
            {:noreply,socket}
    end

  end
  def handle_info(:scroll_chat, socket) do
    {:noreply, push_event(socket, "scroll_chat", %{})}
  end
end
