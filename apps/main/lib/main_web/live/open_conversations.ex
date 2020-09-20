defmodule MainWeb.Live.OpenConverationsView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias Data.Conversations, as: C

  def mount(_params, %{"location_id" => location_id, "header" => true} = session, socket) do
    MainWeb.Endpoint.subscribe("alert:#{location_id}")
    socket =
      socket
      |> assign(:count, open_convos(location_id))
      |> assign(:location_id, location_id)
      |> assign(:header, true)

    {:ok, socket}
  end

  def mount(_params, %{"location_id" => location_id} = session, socket) do
    timer = Enum.random(1000..10_000)
    Main.LiveUpdates.subscribe_live_view(location_id)
    socket =
      socket
      |> assign(:count, open_convos(location_id))
      |> assign(:location_id, location_id)
      |> assign(:header, false)

    {:ok, socket}
  end

  def render(%{count: count, header: true} = assigns) do
    ~L[Open (<%= count %>)]
  end

  def render(%{count: count, header: false} = assigns) do
    ~L[<%= count %>]
  end

  def handle_info(broadcast = %{topic: << "alert:", location_id :: binary >>}, socket) do
    count =
      try do
        open_convos(socket.assigns.location_id)
      rescue
        _ ->
          socket.assigns.count
      end

    {:noreply, assign(socket, %{count: count})}
  end
  def handle_info({_requesting_module, :updated_open}, socket) do
    count = open_convos(socket.assigns.location_id)
    {:noreply, assign(socket, %{count: count})}
  end

  defp open_convos(location_id) do
    %{role: "admin"}
    |> C.all(location_id)
    |> Enum.count(&(&1.status in ["open", "pending"]))
  end
end
