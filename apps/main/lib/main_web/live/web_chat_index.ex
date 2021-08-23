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

      process_name = :"#{id}:#{location.id}"
      Registry.register(Registry.WebChat, process_name, self())

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

  def handle_info({:response, {:unknown, []}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:admin_response, message}, socket) do
    current_location =
      GenServer.call(socket.assigns.event_manager, :current_location)

    location = (current_location || socket.assigns.location)

    response = """
    #{message}
    <br />
    <div class="panel-footer">
      <div class="healthdesk-ai-group">
        <textarea oninput="auto_grow(this)" phx-keyup="send" class="form-control" name="message" placeholder="Type here..." style="width: 100%"></textarea>
      </div>
    </div>
    """

    messages = add_message(%{
          type: "message",
          user: location.location_name,
          direction: "outbound",
          text: response},
      socket.assigns.messages)

    {:noreply, assign(socket, %{messages: messages})}
  end

  def handle_event("send", %{"keyCode" => 13, "value" => message}, socket) do
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
          user: "You",
          direction: "inbound",
          text: message},
      socket.assigns.messages)

    socket = assign(socket, %{messages: messages})

    if conversation.assigns.status == "pending" do
      {:noreply, socket}
    else
      messages = if current_event in [:tour_name, :tour_phone] do
        socket.assigns.event_manager
        |> GenServer.call(current_event)
        |> close_conversation(conversation)
        |> add_message(socket.assigns.messages)

      else
        conversation =
          conversation
          |> P.AskWit.call([],location)
          |> P.BuildAnswer.call([])

        assigns = Map.put(conversation.assigns, :response, conversation.assigns.response)
        conversation = Map.put(conversation, :assigns, assigns)

        response = """
        #{conversation.assigns.response}
        <br />
        <div class="panel-footer">
        <div class="healthdesk-ai-group">
        <textarea oninput="auto_grow(this)" phx-keyup="send" class="form-control" name="message" placeholder="Type here..." style="width: 100%"></textarea>
        </div>
        </div>
        """

        message = %{
          type: "message",
          user: location.location_name,
          direction: "outbound",
          text: response
        }

        message
        |> close_conversation(conversation)
        |> add_message(socket.assigns.messages)
      end

      {:noreply, assign(socket, %{messages: messages})}
    end

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

  def handle_event(_event, _params, socket) do
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

  defp build_answer(_conversation, event, socket) do
    GenServer.call(socket.assigns.event_manager, event)
  end

  defp authorized?(key) do
    Location.get_by_api_key(key)
  end

  defp default_messages(location) do
    [
      %{type: "message",
        user: (if location.web_handle, do: location.web_handle, else: "Webbot"),
        direction: "outbound",
        text: "How may I assist you today? Please choose an option below:"},
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
    |> Enum.map(&disable_textboxes/1)
    |> Enum.reverse()
    |> (fn(messages) -> [message|messages] end).()
    |> Enum.reverse()
  end

  defp disable_textboxes(%{text: text} = message) do
    if String.contains?(text, "class=\"healthdesk-ai-group\"") do
      Map.put(message, :text, String.replace(text, "class=\"healthdesk-ai-group\"", "hidden" ))
    else
      message
    end
  end
  defp disable_textboxes(message), do: message

  defp get_location(id) do
    Location.get(%{role: "admin"}, id)
  end

  defp notify_admin_user(%{message: message, member: member, convo: convo, location: location}) do
    case convo.status do
      "open" ->
        Notify.send_to_teammate(convo.id, message, location, convo.team_member, convo.member )
      _ ->
        Notify.send_to_admin(convo.id, message, location.phone_number, "location-admin")
    end
  end
end
