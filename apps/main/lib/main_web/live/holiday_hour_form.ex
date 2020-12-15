defmodule MainWeb.Live.HolidayHourForm do
  use Phoenix.HTML
  use Phoenix.LiveView

  alias Data.{HolidayHours}
  alias MainWeb.HolidayHourView, as: View


  def render(assigns) do
    View.render("_form.html", assigns)
  end

  def mount(_params,  session, socket) do

    location = session["location"]

    hours = HolidayHours.get_by_location_id(location.id)

    socket = socket
             |> assign(:changeset, HolidayHours.get_changeset())
             |> assign(:rows, [%{open_at: "", close_at: ""}])
             |> assign(:location, location)
             |> assign(:hours, hours)
             |> assign(:holiday_name, "")
             |> assign(:holiday_date, "")
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

  def handle_event("validate", params, socket) do
    {
      :noreply,
      socket
      |> assign(:rows, Map.values params["rows"])
      |> assign(:holiday_name, params["holiday_name"])
      |> assign(:holiday_date, params["holiday_date"])
    }
  end

  def handle_event("save", %{"holiday_name" => holiday_name, "holiday_date" => holiday_date} = params, socket) do

    location = socket.assigns.location

    params = Map.merge(params, %{"times" => socket.assigns.rows, "location_id" => location.id})
             |> Map.merge(%{"holiday_name" => holiday_name, "holiday_date" => holiday_date})

    case HolidayHours.get_by(location.id, holiday_name) do
      nil ->
        HolidayHours.create(params)
      hour ->
        times = Enum.map(hour.times, fn time -> %{"open_at" => time.open_at, "close_at" => time.close_at} end)
        HolidayHours.update(%{"id" => hour.id, "times" => times ++ socket.assigns.rows})
    end
    {
      :noreply,
      socket
      |> redirect(to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/holiday-hours")
    }
  end

  def handle_event("cancel", _params, socket) do

    location = socket.assigns.location
    {
      :noreply,
      socket
      |> redirect(to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/holiday-hours")
    }
  end

  def handle_event("delete", _params, socket) do

    location = socket.assigns.location
    {
      :noreply,
      socket
      |> redirect(to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/holiday-hours")
    }
  end

  def handle_event(event, params, socket) do
    IO.inspect("====================================HANDLE EVENT ERROR====================================")
    IO.inspect(event)
    IO.inspect(params)
    IO.inspect("====================================HANDLE EVENT ERROR======================================")
    {:noreply, socket}
  end

end
