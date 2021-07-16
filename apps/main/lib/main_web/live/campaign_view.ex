defmodule MainWeb.Live.CampaignsView do
  use Phoenix.LiveView, layout: {MainWeb.LayoutView, "live.html"}
  import MainWeb.Helper.LocationHelper
  alias Data.{Campaign,Conversations, Location}

  def render(assigns), do: MainWeb.CampaignView.render("index.html", assigns)

  def mount(_params, session, socket) do
    {:ok, user, _claims} =
      case MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"]) do
        {:error, :token_expired} -> socket |> redirect(to: "/")

        res -> res
      end
    locations = user
                |> teammate_locations()
    campaigns =
      locations
      |> Enum.map(
           fn (location) ->
             Campaign.get_by_location_id(location.id)
           end
         )
      |> List.flatten() |> Enum.sort( &sort/2)

    socket = socket
             |> assign(:locations, locations)
             |> assign(:tab, "campaign")
             |> assign(:loading, false)
             |> assign(:campaigns, campaigns)
             |> assign(:f_campaigns, campaigns)
             |> assign(:user, user)
             |> assign(:current_user, user)
    if connected?(socket), do: Process.send_after(self(), :init_table, 1000)
    {:ok, socket}
  end
  def handle_event("new", _, socket)do
    socket = socket
             |> assign(:new, "new")
             |> assign(:changeset, Conversations.get_changeset())
    if connected?(socket), do: Process.send_after(self(), :menu_fix, 200)

    {:noreply, socket}
  end

  def handle_event("back", _, socket)do

    socket = %{
      socket |
      assigns: Map.delete(socket.assigns, :new),
      changed: Map.put_new(socket.changed, :key, true)
    }
    if connected?(socket), do: Process.send_after(self(), :menu_fix, 200)
    {:noreply, socket}
  end
  def handle_event("refresh", _, socket)do

    campaigns =
      socket.assigns.locations
      |> Enum.map(
           fn (location) ->
             Campaign.get_by_location_id(location.id)
           end
         )
      |> List.flatten() |> Enum.sort( &sort/2)
    socket =
             socket
             |> assign(:campaigns, campaigns)
             |> assign(:f_campaigns, campaigns)
    {:noreply, socket}
  end

  def handle_event("new_msg", %{"conversation" => _c_params, "location_id" => location_id} = params, socket)do

    user = socket.assigns.user
    location = user
               |> Location.get(location_id)

    MainWeb.ConversationController.create_convo(params, location, user)
    campaigns =
      socket.assigns.locations
      |> Enum.map(
           fn (location) ->
             Campaign.get_by_location_id(location.id)
           end
         )
      |> List.flatten() |> Enum.sort( &sort/2)
    socket = %{
               socket |
               assigns: Map.delete(socket.assigns, :new),
               changed: Map.put_new(socket.changed, :key, true)
             }
             |> assign(:campaigns, campaigns)
             |> assign(:f_campaigns, campaigns)
    if connected?(socket), do: Process.send_after(self(), :reload_table, 1000)

    {:noreply, socket}
  end
  def handle_info(:init_table, socket) do
    {:noreply, push_event(socket, "init", %{})}

  end
  def handle_info(:reload_table, socket) do
    if connected?(socket), do: Process.send_after(self(), :menu_fix, 200)
    {:noreply, push_event(socket, "reload", %{})}

  end
  def handle_info(:menu_fix, socket) do
    {:noreply, push_event(socket, "menu_fix", %{})}
  end


  defp sort(c1,c2)do

    t1= Calendar.DateTime.shift_zone!(c1.send_at, c1.location.timezone)
    t2= Calendar.DateTime.shift_zone!(c2.send_at, c2.location.timezone)
    DateTime.compare(t1, t2) == :gt
  end

end