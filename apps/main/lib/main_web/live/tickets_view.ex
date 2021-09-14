defmodule MainWeb.Live.TicketsView do
  use Phoenix.LiveView, layout: {MainWeb.LayoutView, "live.html"}
  import MainWeb.Helper.LocationHelper
  alias Data.{Ticket,TicketNote, Notifications, TeamMember}

  def render(assigns), do: MainWeb.TicketView.render("index.html", assigns)

  def mount(%{"id" => id}, session, socket) do

    {:ok, user, _claims} =
      case MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"]) do
        {:error, :token_expired} -> socket |> redirect(to: "/")
        res -> res
      end
    location_ids = user |> teammate_locations(true)
    locations = user |> teammate_locations()
    socket = socket
             |> assign(:locations, locations)
             |> assign(:location_ids, location_ids)
             |> assign(:tab, "ticket")
             |> assign(:loading, true)
             |> assign(:user, user)
             |> assign(:current_user, user)
             |> assign(:team_members, [])
             |> assign(:tickets, [])
             |> assign(:table_id, gen_reference())
             |> assign(:team_members_all, [])
             |> assign(:changeset, Ticket.get_changeset())
             |> assign(:nchangeset, TicketNote.get_changeset())
             |> assign(:open_ticket, %Data.Schema.Ticket{user_id: "", description: "", team_member_id: "", status: "", priority: "", location_id: "",inserted_at: DateTime.utc_now(),updated_at: DateTime.utc_now(), notes: []})

    send(self(), {:fetch_c, %{user: user, locations: location_ids}})
    send(self(), {:fetch_s, %{id: id}})
    {:ok, socket}

  end
  def mount(_params, session, socket) do
    {:ok, user, _claims} =
      case MainWeb.Auth.Guardian.resource_from_token(session["guardian_default_token"]) do
        {:error, :token_expired} -> socket |> redirect(to: "/")
        res -> res
      end
    location_ids = user |> teammate_locations(true)
    locations = user |> teammate_locations()
    socket = socket
             |> assign(:locations, locations)
             |> assign(:location_ids, location_ids)
             |> assign(:tab, "ticket")
             |> assign(:loading, true)
             |> assign(:user, user)
             |> assign(:current_user, user)
             |> assign(:team_members, [])
             |> assign(:tickets, [])
             |> assign(:table_id, gen_reference())
             |> assign(:team_members_all, [])
             |> assign(:changeset, Ticket.get_changeset())
             |> assign(:nchangeset, TicketNote.get_changeset())
             |> assign(:open_ticket, %Data.Schema.Ticket{user_id: "", description: "", team_member_id: "", status: "", priority: "", location_id: "",inserted_at: DateTime.utc_now(),updated_at: DateTime.utc_now(), notes: []})

    send(self(), {:fetch_c, %{user: user, locations: location_ids}})

    {:ok, socket}

  end
  def handle_info({:fetch_c, %{user: user, locations: locations}}, socket)
    do
    team_members =
      Enum.map(locations,fn(location) ->
        TeamMember.all(user,location)
      end) |> List.flatten() |> Enum.uniq_by(fn tm -> tm.id end)

    team_members_all = Enum.map(team_members, fn x -> {x.user.first_name <> " " <> x.user.last_name, x.id} end)
    tickets = Ticket.get_by_location_ids(socket.assigns.location_ids)
    socket = socket
             |> assign(:team_members, team_members)
             |> assign(:team_members_all, team_members_all)
             |> assign(:tickets, tickets)
             |> assign(:table_id, gen_reference())
    socket = if ((tickets |> List.first) !=nil)  do
      socket
      |> assign(:open_ticket, tickets |> List.first)
    else
      socket

    end


    if connected?(socket), do: Process.send_after(self(), :init_ticket, 3000)
    {:noreply,socket}
  end
  def handle_event("edit_ticket",%{"id" => id}, socket) do
    send(self(), {:fetch_s, %{id: id}})
    {:noreply, assign(socket,loading: true)}
  end
  def handle_info({:fetch_s, %{id: id}}, socket)do
    open_ticket = Ticket.get(id)
    Process.send_after(self(), :open_edit, 3000)
    Process.send_after(self(), :init_ticket, 3000)
    socket = socket
             |> assign(:table_id, gen_reference())
             |> assign(:open_ticket, open_ticket)
    {:noreply, socket}
  end
  def handle_event("new_ticket",%{"ticket" => params}, socket)do
    {:ok, res}=Ticket.create(params)
    tm = TeamMember.get(%{role: "admin"}, res.team_member_id)
    notify(%{user_id: tm.user.id, from: res.user_id, ticket_id: res.id, text: " has assigned you a ticket"})
    Process.send_after(self(), :close_new, 10)
    send(self(), {:fetch_c, %{user: socket.assigns.user, locations: socket.assigns.location_ids}})
    {:noreply, assign(socket,loading: true)}
  end
  def handle_event("update_ticket",%{"ticket" => params}, socket)do
    open_ticket = Ticket.get(params["id"])
    Ticket.update(open_ticket,params)
    {:noreply, socket}
  end
  def handle_event("save_note", %{"ticket_note" => %{"note" => note}= params}, socket)do
    user = socket.assigns.user
    team_members = socket.assigns.team_members
    {_text,notifications} = if note|>String.contains?("@") do
      Enum.reduce(team_members,
        {note,[]}, fn m, {t,n} ->
        if String.contains?(t,"@" <> m.user.first_name <> " " <> m.user.last_name) do
          {
            String.replace(
              t,
              "@" <> m.user.first_name <> " " <> m.user.last_name,
              "<span class='user-tag'>" <> m.user.first_name <> " " <> m.user.last_name <> "</span>"
            ),
            n++[m]
          }
        else
          {t,n}
        end

      end)
    else
      {note,[]}
    end

    Enum.each(notifications,fn n ->
      notify(%{user_id: n.user.id, from: user.id, ticket_id: params["ticket_id"], text: " has mentioned you in a ticket"},n,user)
    end)
    {:ok, res} = TicketNote.create(params)
    #    note =
    TicketNote.get(res.id)
    #    open_ticket=socket.assigns.open_ticket
    #    notes=open_ticket.notes
    #    notes_ = [note|notes]
    #    open_ticket = %{open_ticket | notes: notes_}
    #
    #    socket = socket |> assign(:open_ticket, open_ticket)
    Process.send_after(self(), :close_edit, 10)
    {:noreply, socket}
  end
  def handle_event("close_edit",_, socket)do
    Process.send_after(self(), :close_edit, 10)
    send(self(), {:fetch_c, %{user: socket.assigns.user, locations: socket.assigns.location_ids}})
    {:noreply, assign(socket,loading: true)}
  end

  def handle_info(:menu_fix, socket) do
    {:noreply, push_event(socket, "menu_fix", %{})}
  end
  def handle_info(:open_edit, socket) do
    socket = socket |> assign(:loading, false)
    {:noreply, push_event(socket, "open_edit", %{})}
  end
  def handle_info(:init_ticket, socket) do
    socket = socket |> assign(:loading, false)
    {:noreply, push_event(socket, "init_ticket", %{})}
  end
  def handle_info(:close_new, socket) do
    {:noreply, push_event(socket, "close_new", %{})}
  end
  def handle_info(:close_edit, socket) do
    {:noreply, push_event(socket, "close_edit", %{})}
  end
  defp gen_reference() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
  defp notify(params,_team_member \\nil,_user \\nil)do
    case Notifications.create(params) do
      {:ok, _notif} ->
        Main.LiveUpdates.notify_live_view(params.user_id,{__MODULE__, :new_notif})
      #        MainWeb.Notify.send_to_teammate(params.conversation_id, params.text, team_member,user)
      _ -> nil
    end

  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  def handle_event(_,_params, socket) do
    {:noreply, socket}
  end
end
