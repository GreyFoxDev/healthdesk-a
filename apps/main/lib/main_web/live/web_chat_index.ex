defmodule MainWeb.Live.WebChat.Index do
  use Phoenix.LiveView

  alias Data.Location
  alias Main.WebChat.Supervisor

  def mount(%{api_key: api_key}, socket) do
    with %{} = location <- authorized?(api_key) do
      socket = socket
      |> assign(%{location: location})
      |> assign(%{messages: default_messages()})

      {:ok, event_manager} = Supervisor.start_child(socket.assigns)
      {:ok, assign(socket, %{event_manager: event_manager})}
    else
      nil ->
        socket
        |> assign(%{error: :unauthorized})
        |> (fn(socket) -> {:ok, socket} end).()
    end
  end

  def render(%{error: :unauthorized} = assigns) do
    ~L"""
    <div style="margin: 20px">
      <h2>ERROR: Unauthorized</h2>
      Please provide a valid API KEY to use this service
    </div>
    """
  end

  def render(assigns) do
    MainWeb.WebChat.IndexView.render("index.html", assigns)
  end

  def handle_event("send", %{"message" => message}, socket) do
    messages = add_message(%{
          type: "message",
          user: "Anonymous",
          direction: "inbound",
          text: message},
      socket.assigns.messages)

    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_event("link-click", event, socket) do
    messages =
      socket.assigns.event_manager
      |> GenServer.call(event)
      |> add_message(socket.assigns.messages)

    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_event(event, params, socket) do
    IO.inspect {event, params}
    {:noreply, socket}
  end

  defp authorized?(key) do
    Location.get_by_api_key(key)
  end

  defp default_messages do
    [
      %{type: "message",
        user: "Webbot",
        direction: "outbound",
        text: "How may I assist you today? You can choose from the links below or just type your question."},
      %{type: "link", links: [
           %{value: "join", text: "Join today!"},
           %{value: "pricing", text: "Get pricing info"},
           %{value: "tour", text: "Schedule a tour"},
           %{value: "other", text: "Something else"},
         ]}
    ]
  end

  defp add_message(message, messages) do
    messages
    |> Enum.reverse()
    |> (fn(messages) -> [message|messages] end).()
    |> Enum.reverse()
  end
end
