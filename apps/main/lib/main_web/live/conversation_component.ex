defmodule MainWeb.Live.ConversationComponent do
  use Phoenix.LiveComponent

  alias Data.{Conversations}

  def render(assigns), do: MainWeb.ConversationComponentView.render("conversation.html", assigns)

  def update(assigns, socket) do
    socket = socket
             |> assign(:conversations, assigns.conversations)
             |> assign(:open_conversation, assigns.open_conversation)
             |> assign(:user, assigns.user)
             |> assign(:location_ids, assigns.location_ids)
             |> assign(:page, assigns.page)
             |> assign(:tab, assigns.tab)
             |> assign(:loadmore, assigns.loadmore)

    {:ok, socket}
  end

  def handle_event("loadmore", %{"page" => page} = _params, socket) do
    user = socket.assigns.user

    _status = case socket.assigns.tab do
      "active" -> ["open", "pending"]
      "assigned" -> ["open", "pending"]
      "closed" -> ["closed"]
      _-> []
    end

    socket = if(socket.assigns.loadmore) do

      conversations =
        case socket.assigns.tab do
          "active" -> user
                      |> Conversations.all(socket.assigns.location_ids, ["open", "pending"], (socket.assigns.page * 30)+30,30, user.id,true)
          "assigned" -> user
                        |> Conversations.all(socket.assigns.location_ids, ["open", "pending"], (socket.assigns.page * 30)+30,30, user.id)

          "closed" ->
                      user
                      |> Conversations.all(socket.assigns.location_ids, ["closed"], (socket.assigns.page * 30)+30,30)
          _-> []
        end

      if(conversations == []) do
        socket
        |> assign(:loadmore, false)
      else
        socket
        |> assign(:page, page)
        |> assign(:conversations, socket.assigns.conversations ++ conversations)
      end
    else
      socket
    end

    {:noreply, socket}
  end
end