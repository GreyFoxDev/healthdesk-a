defmodule MainWeb.Live.MessageComponent do
  use Phoenix.LiveComponent
#  alias MainWeb.Live.ConversationsView
  require Logger


  def render(assigns), do: MainWeb.MessageComponentView.render("messages.html", assigns)


  def update(assigns, socket) do
#    IO.inspect("message component update fun-------------")
    socket = socket
             |> assign(:open_conversation, assigns.open_conversation)
             |> assign(:user, assigns.user)
             |> assign(:team_members, assigns.team_members)
             |> assign(:mchangeset, assigns.mchangeset)
             |> assign(:team_members_all, assigns.team_members_all)
             |> assign(:dispositions, assigns.dispositions)
             |> assign(:typing, assigns.typing)
             |> assign(:online, assigns.online)

    {:ok, socket}
  end
end