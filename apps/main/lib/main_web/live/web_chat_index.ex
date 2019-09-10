defmodule MainWeb.Live.WebChat.Index do
  use Phoenix.LiveView

  alias Data.Location
  alias Main.WebChat.Supervisor
  alias MainWeb.Plug, as: P
  alias MainWeb.Notify

  @events %{
    "join" => "Join today!",
    "pricing" => "Get pricing info",
    "tour" => "Schedule a tour",
    "other" => "Something else"
  }
  @main_events Map.keys(@events)

  def mount(%{api_key: api_key, remote_id: id}, socket) do
    with %{} = location <- authorized?(api_key) do
      socket = socket
      |> assign(%{user: id})
      |> assign(%{location: location})
      |> assign(%{messages: default_messages(location)})

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
    current_location =
      GenServer.call(socket.assigns.event_manager, :current_location)

    location = (current_location || socket.assigns.location)
    conversation = %Plug.Conn{
      assigns: %{
        opt_in: true,
        message: message,
        member: socket.assigns.user,
        location: location.phone_number
      }
    }
    |> P.OpenConversation.call([])

    current_event = GenServer.call(socket.assigns.event_manager, :current_event)

    messages = add_message(%{
          type: "message",
          user: "Anonymous",
          direction: "inbound",
          text: message},
      socket.assigns.messages)

    socket = assign(socket, %{messages: messages})

    messages = if current_event in [:tour_name, :tour_phone] do
      socket.assigns.event_manager
      |> GenServer.call(current_event)
      |> close_conversation(conversation)
      |> add_message(socket.assigns.messages)

    else
      conversation =
        conversation
        |> P.AskWit.call([])
        |> P.BuildAnswer.call([])

      message = %{
        type: "message",
        user: socket.assigns.location.location_name,
        direction: "outbound",
        text: conversation.assigns.response
      }

      message
      |> close_conversation(conversation)
      |> add_message(socket.assigns.messages)
    end

    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_event("link-click", event, socket) when event in @main_events do
    location = socket.assigns.location
    conversation = %Plug.Conn{
      assigns: %{
        opt_in: true,
        message: @events[event],
        member: socket.assigns.user,
        location: location.phone_number
      }
    }
    |> P.OpenConversation.call([])

    :ok = notify_admin_user(conversation.assigns)

    messages =
      socket.assigns.event_manager
      |> GenServer.call(event)
      |> close_conversation(conversation)
      |> add_message(socket.assigns.messages)

    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_event("link-click", event, socket) do
    location = socket.assigns.location
    conversation = %Plug.Conn{
      assigns: %{
        opt_in: true,
        message: parse_event(event),
        member: socket.assigns.user,
        location: location.phone_number
      }
    }
    |> P.OpenConversation.call([])

    messages =
      socket.assigns.event_manager
      |> GenServer.call(event)
      |> close_conversation(conversation)
      |> add_message(socket.assigns.messages)

    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_event(event, params, socket) do
    IO.inspect {event, params}
    {:noreply, socket}
  end

  defp parse_event(<< "tour:", rest :: binary >>) do
    String.replace(rest, "-", " ")
  end

  defp parse_event(<< "join:", rest :: binary >>) do
    String.replace(rest, "-", " ")
  end

  defp parse_event(<< "location:", id :: binary >>) do
    location = get_location(id)
    location.location_name
  end

  defp close_conversation(message, conversation) do
    assigns = Map.put(conversation.assigns, :response, message.text)

    conversation
    |> Map.put(:assigns, assigns)
    |> P.CloseConversation.call([])

    message
  end

  defp build_answer(conversation, event, socket) do
    response = GenServer.call(socket.assigns.event_manager, event)
  end

  defp authorized?(key) do
    Location.get_by_api_key(key)
  end

  defp default_messages(location) do
    [
      %{type: "message",
        user: (if location.web_handle, do: location.web_handle, else: "Webbot"),
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

  defp get_location(id) do
    Location.get(%{role: "admin"}, id)
  end

  defp notify_admin_user(%{message: message, member: member, convo: convo, location: location}) do
    message = """
    Message From: #{member}\n
    #{message}
    """

    :ok = Notify.send_to_admin(convo, message, location)

  end
end
