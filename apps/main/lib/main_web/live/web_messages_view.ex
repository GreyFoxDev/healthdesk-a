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
        |> assign(:messages, messages)

      {:ok, socket}
    else
      nil ->
        {:ok, assign(socket, %{error: :unauthorized})}
    end
  end

  def handle_info({:update, convo_id}, socket) do
    messages = Data.ConversationMessages.get_by_conversation_id(convo_id)
    {:noreply, assign(socket, :messages, messages)}
  end
end
