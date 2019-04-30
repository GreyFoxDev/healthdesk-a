defmodule MainWeb.Live.ConversationMessageUpdatesView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.ConversationMessageUpdatesView, as: View

  def render(%{messages: messages} = assigns), do: View.render("index.html", assigns)

  def render(assigns) do
    ~L[]
  end

  def mount(session, socket) do
    MainWeb.Endpoint.subscribe("convo:#{session.conversation}")
    {:ok, assign(socket, :session, session)}
  end

  def handle_info(broadcast = %{topic: << "convo:", _id :: binary >>}, socket) do
    messages = if socket.assigns, do: (socket.assigns[:messages] || []), else: []
    {:noreply, assign(socket, :messages, [broadcast.payload|messages])}
  end
end
