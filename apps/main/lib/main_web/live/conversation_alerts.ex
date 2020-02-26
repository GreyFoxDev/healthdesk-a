defmodule MainWeb.Live.ConversationAlertsView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias MainWeb.Router.Helpers, as: Routes

  def render(%{alert: %{convo: convo, location: location}} = assigns) do
    ~L[
    <div class="alert alert-info alert-dismissible fade show">
      <b>New message for <%= link location.location_name, to: "/admin/teams/#{location.team_id}/locations/#{location.id}/conversations/#{convo}/conversation-messages" %> location</b>
    </div>
    ]
  end

  def render(assigns) do
    ~L[]
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
    {:noreply, assign(socket, :alert, broadcast.payload)}
  end
end
