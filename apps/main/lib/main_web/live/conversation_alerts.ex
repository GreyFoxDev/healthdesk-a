defmodule MainWeb.Live.ConversationAlertsView do
  use Phoenix.HTML
  use Phoenix.LiveView


  alias MainWeb.ConversationAlertsView, as: View
  
  def render(assigns) do
    View.render("index.html", assigns)
  end

  def mount(_params, %{"current_user" => %{role: "admin"}} = session, socket) do
    MainWeb.Endpoint.subscribe("alert:admin")
    {:ok, assign(socket, :session, session)}
  end

  def mount(_params, %{"current_user" => %{team_member: %{locations: locations}}} = session, socket) when is_list(locations) do
    Enum.each(locations, fn(location) ->
      MainWeb.Endpoint.subscribe("alert:#{location.phone_number}")
    end)

    {:ok, assign(socket, :session, session)}
  end

  def mount(_params, %{"current_user" => %{team_member: %{location_id: location_id}}} = session, socket) do
    location = Data.Location.get(location_id)

    MainWeb.Endpoint.subscribe("alert:#{location.phone_number}")
    {:ok, assign(socket, :session, session)}
  end

  def mount(_params, session, socket) do
    {:ok, assign(socket, :session, session)}
  end

  def handle_info(broadcast = %{topic: << "alert:", _loation :: binary >>}, socket) do
    {:noreply, assign(socket, alert: broadcast.payload, randid: UUID.uuid4())}
  end
end
