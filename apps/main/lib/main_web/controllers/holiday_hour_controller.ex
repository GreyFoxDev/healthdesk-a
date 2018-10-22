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

    render conn, "index.html", location: location, hours: hours
  end

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      changeset: HolidayHours.get_changeset(),
      location: location,
      errors: [])
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- HolidayHours.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        location: location,
        errors: [])
    end
  end

  def create(conn, %{"holiday_hour" => hours, "team_id" => team_id, "location_id" => location_id} = params) do
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
           |> render_page("new.html", changeset, changeset.errors)
       end
  end

  def update(conn, %{"id" => id, "holiday_hour" => hours, "team_id" => team_id, "location_id" => location_id}) do
    hours
    |> Map.merge(%{"id" => id, "location_id" => location_id})
    |> HolidayHours.update()
    |> case do
         {:ok, _hours} ->
           location =
             conn
             |> current_user()
             |> Location.get(location_id)

           conn
           |> put_flash(:success, "Holiday Hours updated successfully.")
           |> redirect(to: team_location_holiday_hour_path(conn, :index, team_id, location_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Holiday Hours failed to update")
           |> render_page("edit.html", changeset, changeset.errors)
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
           |> render_page("index.html", team_id, location_id)
       end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
