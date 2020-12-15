defmodule MainWeb.Live.NotificationsView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.Router.Helpers, as: Routes
  alias MainWeb.NotificationsView, as: View
  alias Data.{Notifications, Conversations}

  def render(assigns) do
    View.render("index.html", assigns)
  end

  def mount(_params, session, socket) do
    Main.LiveUpdates.subscribe_live_view(session["current_user"].id)
    notifications = Notifications.get_by_user(session["current_user"].id)
    read= Enum.reduce_while(notifications, false, fn x, acc ->
      if x.read, do: {:cont, false}, else: {:halt, true}
    end)
    socket= socket
            |> assign( :session, session)
            |> assign( :read, read)
            |> assign(:current_user, session["current_user"])
    {:ok, socket}
  end

  def handle_info({_requesting_module, :plzzwork}, socket) do
    socket= socket
            |> assign(:read, true)
    {:noreply, socket}
  end

end