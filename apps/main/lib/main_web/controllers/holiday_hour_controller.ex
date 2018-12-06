defmodule MainWeb.HolidayHourController do
  use MainWeb.SecuredContoller

  alias Data.{HolidayHours, Location}

  def index(conn, %{"location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours =
      conn
      |> current_user()
      |> HolidayHours.all(location_id)

    render conn, "index.html", location: location, hours: hours, teams: teams(conn), changeset: HolidayHours.get_changeset()
  end

  def create(conn, %{"holiday_hour" => hours, "team_id" => team_id, "location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours
    |> Map.put("location_id", location_id)
    |> HolidayHours.create()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Holiday Hours created successfully.")
           |> redirect(to: team_location_holiday_hour_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Holiday Hours failed to create")
           |> render("index.html", location: location, hours: hours, teams: teams(conn), changeset: changeset, errors: changeset.errors)
       end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id, "location_id" => location_id}) do
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> HolidayHours.update()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Holiday Hours deleted successfully.")
           |> redirect(to: team_location_holiday_hour_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Holiday Hours failed to delete")
           |> redirect(to: team_location_holiday_hour_path(conn, :index, team_id, location_id))
       end
  end
end
