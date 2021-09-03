defmodule MainWeb.Live.OpenConverationsView do
  use Phoenix.HTML
  use Phoenix.LiveView
  import MainWeb.Helper.LocationHelper
  alias Data.Conversations, as: C




  def mount(_params, %{ "current_user" => current_user, "convo_type" => convo_type} = session, socket) do


    location_ids = teammate_locations(current_user,true)

    Main.LiveUpdates.subscribe_live_view()
    team_member_id=
      if is_nil(current_user.team_member) do
          nil
        else
          current_user.team_member.id
      end
    socket =
      socket
      |> assign(:count, open_convos(location_ids,team_member_id))
      |> assign(:current_user, current_user)
      |> assign(:team_member_id, team_member_id)
      |> assign(:session, session)
      |> assign(:location_ids, location_ids)
      |> assign(:header, false)
      |> assign(:convo_type, convo_type)

    {:ok, socket}
  end
  def mount(_params, %{ "location_id" => location_id} = _session, socket) do

    Main.LiveUpdates.subscribe_live_view(location_id)

    socket =
      socket
      |> assign(:count, 0) #!!!Reminder open_convos() has to be called
      |> assign(:location_ids, location_id)
      |> assign(:header, false)

    {:ok, socket}
  end

  def render(%{count: count, header: false, convo_type: convo_type} = assigns) do
    case convo_type do
      :convo ->
        count=count["total"]
        ~L[<%= count %>]
      :active ->
        count=count["active_count"]
        ~L[<%= count %>]
      :assigned ->
        count=count["assigned_count"]
        ~L[<%= count %>]
      :closed ->
        count=count["closed_count"]
        ~L[<%= count %>]
      _ ->
      ~L[<%=0%>]


    end
  end

  def handle_info(_broadcast = %{topic: << "alert:", _location_id :: binary >>}, socket) do
    count =
      try do
        open_convos(socket.assigns.location_ids, socket.assigns.team_member_id)
      rescue
        _ ->
          socket.assigns.count
      end

    {:noreply, assign(socket, %{count: count})}
  end
  def handle_info(:menu_fix, socket) do
    {:noreply, push_event(socket, "menu_fix", %{})}
  end

  def handle_info({location_id, :updated_open}, socket) do
    count =
      if Enum.any?(socket.assigns.location_ids, fn x -> x == location_id end) do
        open_convos(socket.assigns.location_ids, socket.assigns.team_member.id)
      else
        socket.assigns.count
      end

    if count != socket.assigns.count do
      if connected?(socket), do: Process.send_after(self(), :menu_fix, 300)
      {:noreply, assign(socket, %{count: count})}
    else
      {:noreply, socket}

    end
  end
  def handle_info({location_id, :updated_count}, socket) do
    count =
      if Enum.any?(socket.assigns.location_ids, fn x -> x == location_id end) do
        open_convos(socket.assigns.location_ids, socket.assigns.team_member.id)
      else
        socket.assigns.count
      end

    if count != socket.assigns.count do
      if connected?(socket), do: Process.send_after(self(), :menu_fix, 300)
      {:noreply, assign(socket, %{count: count})}
    else
      {:noreply, socket}

    end
  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  defp open_convos(location_id, team_member_id) do
    active= C.count_active_convo(location_id, team_member_id)
    assigned = C.count_assigned_convo(location_id, team_member_id)
    closed=C.count_closed_convo(location_id)

    %{"active_count"=> active, "assigned_count"=> assigned, "total"=> active+assigned, "closed_count"=> closed }
  end
end
