defmodule MainWeb.Live.OpenConverationsView do
  use Phoenix.HTML
  use Phoenix.LiveView
  import MainWeb.Helper.LocationHelper
  alias Data.Conversations, as: C


  def mount(_params, %{ "current_user" => current_user} = session, socket) do

    location_ids = teammate_locations(current_user,true)

    Main.LiveUpdates.subscribe_live_view()
    socket =
      socket
      |> assign(:count, open_convos(location_ids))
      |> assign(:current_user, current_user)
      |> assign(:session, session)
      |> assign(:location_ids, location_ids)
      |> assign(:header, false)

    {:ok, socket}
  end
  def mount(_params, %{ "location_id" => location_id} = _session, socket) do

    Main.LiveUpdates.subscribe_live_view(location_id)
    socket =
      socket
      |> assign(:count, open_convos(location_id))
      |> assign(:location_ids, location_id)
      |> assign(:header, false)

    {:ok, socket}
  end

  def render(%{count: count, header: false} = assigns) do
    ~L[<%= count %>]
  end

  def handle_info(broadcast = %{topic: << "alert:", location_id :: binary >>}, socket) do
    IO.inspect("###################")
    IO.inspect("broadcast")
    IO.inspect("###################")

    count =
      try do
        open_convos(socket.assigns.location_ids)
      rescue
        _ ->
          socket.assigns.count
      end

    {:noreply, assign(socket, %{count: count})}
  end
  def handle_info({location_id, :updated_open}, socket) do
    IO.inspect("###################")
    IO.inspect("updated_open")
    IO.inspect(location_id)
    IO.inspect("###################")

    count =
      if Enum.any?(socket.assigns.location_ids, fn x -> x == location_id end) do
        open_convos(socket.assigns.location_ids)
      else
        socket.assigns.count
      end
    {:noreply, assign(socket, %{count: count})}
  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  defp open_convos(location_id) do
    %{role: "admin"}
    |> C.all(location_id)
    |> Enum.count(&(&1.status in ["open", "pending"]))
  end
end
