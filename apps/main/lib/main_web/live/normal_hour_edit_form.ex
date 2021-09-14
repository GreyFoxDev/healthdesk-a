defmodule MainWeb.Live.NormalHourEditForm do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias Data.{NormalHours}
  alias MainWeb.NormalHourView, as: View


  def render(assigns) do
    View.render("_form.html", assigns)
  end

  def mount(_params,  session, socket) do

    location = session["location"]

    hours = NormalHours.get_by_location_id(location.id)

    socket = socket
             |> assign(:changeset, NormalHours.get_changeset())
             |> assign(:rows, session["rows"])
             |> assign(:location, location)
             |> assign(:hours, hours)
             |> assign(:day_of_week, session["day_of_week"])
             |> assign(:closed, session["closed"])
             |> assign(:action, session["action"])

    {:ok, socket}
  end

  def handle_event("add", _params, socket) do

    rows = socket.assigns.rows

    rows = if rows && rows == [] do
      [%{open_at: "", close_at: ""}]
    else
      rows ++ [%{open_at: "", close_at: ""}]
    end
    {
      :noreply,
      socket
      |> assign(:rows, rows)
    }
  end

  def handle_event("remove", %{"index" => index}, socket) do

    rows = socket.assigns.rows
    {
      :noreply,
      socket
      |> assign(:rows, List.delete_at(rows, String.to_integer(index)))
    }
  end

  def handle_event("validate", %{"closed" => closed} = params, socket) do
    closed =  if(closed == "true") do true else false end

    {
      :noreply,
      socket
      |> assign(:rows, Map.values params["rows"])
      |> assign(:day_of_week, params["day_of_week"])
      |> assign(:closed, closed)
    }
  end

  def handle_event("save",
        %{"day_of_week" => day_of_week, "closed" => closed} = params, socket) do

    location = socket.assigns.location

    params = Map.merge(params, %{"times" => socket.assigns.rows, "location_id" => location.id})
             |> Map.merge(%{"day_of_week" => day_of_week, "closed" => closed})

    case NormalHours.get_by(location.id, day_of_week) do
      nil ->
        NormalHours.create(params)
      hour ->
        _times = Enum.map(hour.times, fn time -> %{"open_at" => time.open_at, "close_at" => time.close_at} end)
        NormalHours.update(%{"id" => hour.id, "closed" => closed, "times" => socket.assigns.rows})
    end
    {
      :noreply,
      socket
      |> redirect(to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/normal-hours")
    }
  end

  def handle_event("cancel", _params, socket) do

    location = socket.assigns.location
    {
      :noreply,
      socket
      |> redirect(to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/normal-hours")
    }
  end

  def handle_event(event, params, socket) do
    {:noreply, socket}
  end

end
