defmodule MainWeb.Live.WebMessagesView do
  use Phoenix.LiveView

  alias Data.Schema.{Location}
  alias Data.{ConversationMessages}
  alias Data.Schema.MemberChannel, as: Channel
  alias Data.Schema.MemberChannel

  require Logger

  def render(assigns),
    do: MainWeb.WebMessageView.render("messages.html", assigns)

  def mount(_params, %{"api_key" => api_key, "convo_id" => convo_id}, socket) do
    with %Location{} = location <- Data.Location.get_by_api_key(api_key),
         conversation <- Data.Conversations.get(convo_id) do

      messages = Data.ConversationMessages.get_by_conversation_id(convo_id)

      Task.start(fn -> Enum.each(messages, fn(msg) -> if msg.read == false, do: mark_read(convo_id,msg),else: nil end) end)
      if connected?(socket), do: :timer.send_interval(3000, self(), {:update, convo_id})

      socket =
        socket
        |> assign(:original_number, conversation.original_number)
        |> assign(:convo_id, convo_id)
        |> assign(:api_key, api_key)
        |> assign(:messages, messages)
        |> assign(:location, location)
        |> assign(:member, conversation.team_member)
      Main.LiveUpdates.subscribe_live_view(convo_id)
      MainWeb.Endpoint.subscribe("convo:#{convo_id}")
      Main.LiveUpdates.notify_live_view({convo_id, :user_typing_stop})

      {:ok, socket}
    else
      nil ->
        {:ok, assign(socket, %{error: :unauthorized})}
    end
  end

  def handle_info({:update, convo_id}, socket) do
    Main.LiveUpdates.notify_live_view({convo_id, :online})
    {:noreply, socket}
  end
  def terminate(_reason, socket) do
    convo_id = socket.assigns.convo_id
    Main.LiveUpdates.notify_live_view({convo_id, :offline})

  end
  def handle_event("focused",_,socket)do
    convo_id = socket.assigns.convo_id
    Main.LiveUpdates.notify_live_view({convo_id, :user_typing_start})
    {:noreply, socket}

  end
  def handle_event("blured",_,socket)do
    convo_id = socket.assigns.convo_id
    Main.LiveUpdates.notify_live_view({convo_id, :user_typing_stop})
    {:noreply, socket}
  end

  def handle_info({_requesting_module, :agent_typing_start}, socket) do
    {:noreply, assign(socket, %{typing: true})}
  end
  def handle_info({_requesting_module, :agent_typing_stop}, socket) do
    {:noreply, assign(socket, %{typing: false})}
  end
  def handle_info({_requesting_module, {:new_msg,msg}}, socket) do
     socket.assigns.convo_id |> mark_read(msg)

    messages = if socket.assigns, do: (socket.assigns[:messages] || []), else: []
    messages = messages ++ [msg]
    socket =
      socket
      |> assign(:messages, messages)
    {:noreply, socket}
  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  def handle_event(_,_params, socket) do
    {:noreply, socket}
  end
  def fetch_member(%{original_number: <<"CH", _rest :: binary>> = channel} = conversation) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel) do
      Map.put(conversation, :member, channel.member)
    end
  end
  def fetch_member(conversation), do: conversation
  defp mark_read(convo_id,msg) do
    {:ok, msg}= ConversationMessages.mark_read(msg)
    Main.LiveUpdates.notify_live_view({convo_id, msg})

  end

end
