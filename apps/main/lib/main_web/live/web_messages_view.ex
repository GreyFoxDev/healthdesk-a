defmodule MainWeb.Live.WebMessagesView do
  use Phoenix.LiveView

  alias Data.Schema.{Location, Conversation}

  require Logger

  def render(assigns),
    do: MainWeb.WebMessageView.render("messages.html", assigns)

  def mount(_params, %{"api_key" => api_key, "convo_id" => convo_id}, socket) do
    with %Location{} = location <- Data.Location.get_by_api_key(api_key),
         conversation <- Data.Conversations.get(convo_id) do

      messages = Data.ConversationMessages.get_by_conversation_id(convo_id)

      if connected?(socket), do: :timer.send_interval(3000, self(), {:update, convo_id})

      socket =
        socket
        |> assign(:original_number, conversation.original_number)
        |> assign(:convo_id, convo_id)
        |> assign(:api_key, api_key)
        |> assign(:messages, messages)
      Main.LiveUpdates.subscribe_live_view(convo_id)
      MainWeb.Endpoint.subscribe("convo:#{convo_id}")
      Main.LiveUpdates.notify_live_view(convo_id,{__MODULE__, :user_typing_stop})

      {:ok, socket}
    else
      nil ->
        {:ok, assign(socket, %{error: :unauthorized})}
    end
  end

  def handle_info({:update, convo_id}, socket) do
    Main.LiveUpdates.notify_live_view(convo_id,{__MODULE__, :online})
    {:noreply, socket}
  end
  def terminate(reason, socket) do
    convo_id = socket.assigns.convo_id
    Main.LiveUpdates.notify_live_view(convo_id,{__MODULE__, :offline})

  end
  def handle_event("focused",_,socket)do
    convo_id = socket.assigns.convo_id
    Main.LiveUpdates.notify_live_view(convo_id,{__MODULE__, :user_typing_start})
    {:noreply, socket}

  end
  def handle_event("blured",_,socket)do
    convo_id = socket.assigns.convo_id
    Main.LiveUpdates.notify_live_view(convo_id,{__MODULE__, :user_typing_stop})
    {:noreply, socket}
  end

  def handle_info({_requesting_module, :agent_typing_start}, socket) do
    {:noreply, assign(socket, %{typing: true})}
  end
  def handle_info({_requesting_module, :agent_typing_stop}, socket) do
    {:noreply, assign(socket, %{typing: false})}
  end
  def handle_info({_requesting_module, {:new_msg,msg}}, socket) do
    IO.inspect("###################")
    IO.inspect(msg)
    IO.inspect("###################")

    messages = if socket.assigns, do: (socket.assigns[:messages] || []), else: []
    IO.inspect("###################")
    IO.inspect(length(messages))
    IO.inspect("###################")
    messages = [msg | messages]
    IO.inspect("###################")
    IO.inspect(length(messages))
    IO.inspect("###################")
   socket =
      socket
      |> assign(:messages, messages)
    IO.inspect("###################")
    IO.inspect(length(socket.assigns[:messages]))
    IO.inspect("###################")
    {:noreply, socket}
  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end

end
