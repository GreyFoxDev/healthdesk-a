defmodule MainWeb.Live.NotificationsView do
  use Phoenix.HTML
  use Phoenix.LiveView


  alias MainWeb.NotificationsView, as: View
  alias Data.{Notifications}

  def render(assigns) do
    View.render("index.html", assigns)
  end

  def mount(_params, session, socket) do
    Main.LiveUpdates.subscribe_live_view_and_track(session["current_user"].id)
    notifications = Notifications.get_by_user(session["current_user"].id)
    socket = socket
             |> assign(:session, session)
             |> assign(:current_user, session["current_user"])
             |> assign(:notifications, notifications)
    read = Enum.reduce_while(
      notifications,
      false,
      fn x, _acc ->
        if !x.read, do: {:halt, true}, else: {:cont, false}
      end
    )
    socket = socket
             |> assign(:read, read)
    {:ok, socket}
  end

  def handle_info({_requesting_module, :new_notif}, socket) do
    notifications = Notifications.get_by_user(socket.assigns.current_user.id)
    socket = socket
             |> assign(:notifications, notifications)
    {:noreply, socket}
  end

#  calling just for presence flow
  def handle_info(_rest_socket, socket) do
    notifications = Notifications.get_by_user(socket.assigns.current_user.id)
    socket = socket
             |> assign(:notifications, notifications)
    {:noreply, socket}
  end

  def handle_event("conversation", params, socket) do
    Notifications.update(%{"id" => params["nid"], "read" => true})
    notifications = Notifications.get_by_user(socket.assigns.current_user.id)
    read = Enum.reduce_while(
      notifications,
      false,
      fn x, _acc ->
        if !x.read, do: {:halt, true}, else: {:cont, false}
      end
    )
    socket = socket
             |> assign(:read, read)
             |> assign(:notifications, notifications)
    url = if params["cid"] do
      "/admin/conversations/#{params["cid"]}/notes"

    else
      if params["tid"] do
        "/admin/tickets/#{params["tid"]}"
      end
    end
    Process.send_after(self(), {:update_notif, %{url: url}},300)
    {:noreply, socket}
  end

  def handle_info({:update_notif, %{url: url}}, socket) do
    Main.LiveUpdates.notify_live_view(socket.assigns.current_user.id,{__MODULE__, :new_notif})
    {
      :noreply,
      socket
      |> redirect(to: url)
    }

  end

end