defmodule MainWeb.Live.ConversationComponent do
  use Phoenix.LiveComponent

  def render(assigns), do: MainWeb.ConversationComponentView.render("conversation.html", assigns)

  def update(assigns, socket) do

#    IO.inspect("conversation component update fun-------------")
    socket = socket
             |> assign(:conversations, assigns.conversations)
             |> assign(:open_conversation, assigns.open_conversation)
             |> assign(:user, assigns.user)
             |> assign(:location_ids, assigns.location_ids)

    {:ok, socket}
  end
end