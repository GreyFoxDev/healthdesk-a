defmodule MainWeb.Live.ConversationMessageUpdatesView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.ConversationMessageUpdatesView, as: View

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

  def handle_info(broadcast = %{topic: << "convo:", _id :: binary >>}, socket) do
    messages = if socket.assigns, do: (socket.assigns[:messages] || []), else: []
    {:noreply, assign(socket, :messages, [broadcast.payload|messages])}
  end
end
