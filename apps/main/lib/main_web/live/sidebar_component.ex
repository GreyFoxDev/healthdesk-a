defmodule MainWeb.Live.SidebarComponent do
  use Phoenix.LiveComponent

#  import MainWeb.Helper.Formatters
#  import MainWeb.Helper.MemberOptions

  def render(assigns), do: MainWeb.SidebarComponentView.render("sidebar.html", assigns)

  def update(assigns, socket) do
    socket = socket
             |> assign(:open_conversation, assigns.open_conversation)
             |> assign(:tab1, assigns.tab1)
             |> assign(:notes, assigns.notes)
             |> assign(:team_members, assigns.team_members)
             |> assign(:saved_replies, assigns.saved_replies)

    {:ok, socket}
  end
end