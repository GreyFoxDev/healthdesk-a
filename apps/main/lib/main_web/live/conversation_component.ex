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

  def handle_event("loadmore", %{"page" => page} = params, socket) do
    user = socket.assigns.user

    status = case socket.assigns.tab do
      "active" -> ["open", "pending"]
      "assigned" -> ["open", "pending"]
      "closed" -> ["closed"]
      _-> []
    end

    socket = if(socket.assigns.loadmore) do
      conversations =
        user
        |> Conversations.all(socket.assigns.location_ids, status, (socket.assigns.page * 10)+20)
      IO.inspect("=======================START=======================")
      IO.inspect(Enum.count(conversations))
      IO.inspect(Enum.count(socket.assigns.conversations))
      IO.inspect("=======================END=======================")

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