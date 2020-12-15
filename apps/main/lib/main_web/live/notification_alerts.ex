defmodule MainWeb.Live.NotificationAlertsView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.Router.Helpers, as: Routes
  alias MainWeb.NotificationAlertsView, as: View
  alias Data.{Notifications, Conversations}


  def render(assigns) do
    View.render("show.html", assigns)
  end

  def mount(_params,  session, socket) do
    Main.LiveUpdates.subscribe_live_view(session["current_user"].id)
    notifications = Notifications.get_by_user(session["current_user"].id)
    socket= socket
    |> assign( :session, session)
    |> assign(:current_user, session["current_user"])
    |> assign(:notifications, notifications)
    {:ok, socket}
  end

  def handle_info({_requesting_module, :new_notif}, socket) do
    notifications =  Notifications.get_by_user(socket.assigns.current_user.id)
    socket= socket
            |> assign(:notifications, notifications)
    {:noreply, socket}
  end

  def handle_event("conversation", params, socket) do
    if params["cid"] do
      conversation =
        socket.assigns.current_user
        |> Conversations.get(params["cid"])
      Task.start(fn ->
        Notifications.update(%{"id" => params["nid"], "read" => true})
      end)

      {:noreply,
        socket
        |> redirect(to: "/admin/conversations/#{conversation.id}" )
      }
    end
    if params["tid"] do
      Task.start(fn ->
        Notifications.update(%{"id" => params["nid"], "read" => true})
      end)

      {:noreply,
        socket
        |> redirect(to: "/admin/tickets/#{params["tid"]}" )
      }
    end

  end

end
