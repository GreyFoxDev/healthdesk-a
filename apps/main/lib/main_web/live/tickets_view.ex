defmodule MainWeb.Live.TicketsView do
  use Phoenix.LiveView, layout: {MainWeb.LayoutView, "live.html"}
  import MainWeb.Helper.LocationHelper

  def render(assigns), do: MainWeb.TicketView.render("index.html", assigns)

  def mount(_params, session, socket) do
    {:ok, user, claims} = MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"])

    locations = user
                |> teammate_locations()

    socket = socket
             |> assign(:locations, locations)
             |> assign(:tab, "ticket")
             |> assign(:loading, false)
             |> assign(:user, user)
             |> assign(:current_user, user)

    {:ok, socket}

  end

end
