defmodule MainWeb.HolidayHourController do
  use MainWeb.SecuredContoller

  alias Data.{HolidayHours, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours =
      conn
      |> current_user()
      |> HolidayHours.all(location_id)

    render(
      conn,
      "index.html",
      location: location,
      hours: hours,
      teams: teams(conn),
      changeset: HolidayHours.get_changeset(),
      rows: [%{open_at: "", close_at: ""}],
      holiday_name: "",
      holiday_date: ""
    )
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours = HolidayHours.get_by_location_id(location_id)

    hour = Enum.filter(hours, fn f -> f.id == id  end) |> List.first()

    rows = Enum.map(hour.times, fn time -> %{"open_at" => time.open_at, "close_at" => time.close_at} end)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- HolidayHours.get_changeset(id, user) do

      date = DateTime.to_iso8601(changeset.data.holiday_date)
      date = hd(String.split(date, "T"))

      render(conn, "edit.html",
        changeset: changeset,
        location: location,
        hours: hours,
        rows: rows,
        holiday_name: "#{changeset.data.holiday_name}",
        closed: changeset.data.closed,
        holiday_date: date,
        errors: [])
    end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id, "location_id" => location_id}) do
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> HolidayHours.update()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Special Hours deleted successfully.")
           |> redirect(to: team_location_holiday_hour_path(conn, :index, team_id, location_id))

         {:error, _changeset} ->
           conn
           |> put_flash(:error, "Special Hours failed to delete")
           |> redirect(to: team_location_holiday_hour_path(conn, :index, team_id, location_id))
       end
  end

end
