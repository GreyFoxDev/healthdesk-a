defmodule MainWeb.Live.OpenConverationsView do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias Data.Conversations, as: C

  def mount(%{location_id: location_id, header: true} = session, socket) do
    timer = Enum.random(1000..10_000)
    :timer.send_interval(timer, self(), :update)

    socket =
      socket
      |> assign(:count, open_convos(location_id))
      |> assign(:location_id, location_id)
      |> assign(:header, true)

    {:ok, socket}
  end

  def mount(%{location_id: location_id} = session, socket) do
    :timer.send_interval(100, self(), :update)
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

  def handle_info(:update, socket) do
    {:noreply, assign(socket, %{count: open_convos(socket.assigns.location_id)})}
  end

  defp open_convos(location_id) do
    %{role: "admin"}
    |> C.all(location_id)
    |> Enum.count(&(&1.status in ["open", "pending"]))
  end
end
