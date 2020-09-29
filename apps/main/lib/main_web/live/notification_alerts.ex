defmodule MainWeb.Live.NotificationAlertsView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.Router.Helpers, as: Routes
  alias MainWeb.NotificationAlertsView, as: View
  alias Data.{Notifications, Conversations}


  def render(assigns) do
    View.render("index.html", assigns)
  end

  def mount(_params,  session, socket) do
    Main.LiveUpdates.subscribe_live_view(session["current_user"].id)
    notifications = Notifications.get_by_user(session["current_user"].id)
    read= Enum.reduce_while(notifications, false, fn x, acc ->
      if x.read, do: {:cont, false}, else: {:halt, true}
    end)
    socket= socket
    |> assign( :session, session)
    |> assign( :read, read)
    |> assign(:current_user, session["current_user"])
    |> assign(:notifications, notifications)
    {:ok, socket}
  end

  def handle_info({_requesting_module, :new_notif}, socket) do
    notifications =  Notifications.get_by_user(socket.assigns.current_user.id)
    socket= socket
            |> assign(:notifications, notifications)
            |> assign(:read, true)
    {:noreply, socket}
  end

  def handle_event("conversation", params, socket) do
    conversation =
      socket.assigns.current_user
      |> Conversations.get(params["cid"])
    IO.inspect("###################")
    IO.inspect(conversation)
    IO.inspect("###################")
    Task.start(fn ->
      Notifications.update(%{"id" => params["nid"], "read" => true})
    end)

        {:noreply,
      socket
      |> redirect(to: "/admin/teams/#{conversation.location.team_id}/locations/#{conversation.location.id}/conversations/#{conversation.id}/conversation-messages" )
    }
  end

end
