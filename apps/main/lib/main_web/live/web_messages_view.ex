defmodule MainWeb.Live.WebMessagesView do
  use Phoenix.LiveView

  alias Data.Schema.{Location, Conversation}

  require Logger

  def render(assigns) do
    MainWeb.WebMessageView.render("messages.html", assigns)
  end

  def mount(%{api_key: api_key, convo_id: convo_id}, socket) do
    with %Location{} = location <- Data.Location.get_by_api_key(api_key),
         conversation <- Data.Conversations.get(convo_id) do

      messages = Data.ConversationMessages.get_by_conversation_id(convo_id)

      if connected?(socket), do: :timer.send_interval(1000, self(), {:update, convo_id})

      socket =
        socket
        |> assign(:location, location)
        |> assign(:conversation, conversation)
        |> assign(:messages, messages)

      {:ok, socket}
    else
      nil ->
        {:ok, assign(socket, %{error: :unauthorized})}
    end
  end

  def handle_info({:update, convo_id}, socket) do
    IO.inspect "UPDATING MESSAGES *****"
    messages = Data.ConversationMessages.get_by_conversation_id(convo_id)
    IO.inspect messages
    {:noreply, assign(socket, :messages, messages)}
  end

  def terminate(reason, socket) do
    IO.inspect reason, label: "TERMINATION **********"
    {:ok, socket}
  end

end
