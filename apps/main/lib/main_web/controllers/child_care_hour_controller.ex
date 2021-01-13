defmodule MainWeb.ChildCareHourController do
  use MainWeb.SecuredContoller

  alias Data.{ChildCareHours, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours = ChildCareHours.get_by_location_id(location_id)

    render(
      conn, "index.html",
      location: location,
      hours: hours,
      teams: teams(conn),
      changeset: ChildCareHours.get_changeset(),
      rows: [%{morning_open_at: "", morning_close_at: "",
        afternoon_open_at: "", afternoon_close_at: ""}]
    )
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours = ChildCareHours.get_by_location_id(location_id)

    hour = Enum.filter(hours, fn f -> f.id == id  end) |> List.first()

    rows = Enum.map(hour.times, fn
      time ->
      %{"morning_open_at" => time.morning_open_at, "morning_close_at" => time.morning_close_at,
        "afternoon_open_at" => time.afternoon_open_at, "afternoon_close_at" => time.afternoon_close_at}
    end)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- ChildCareHours.get_changeset(id, user) do

      render(
        conn,
        "edit.html",
        changeset: changeset,
        location: location,
        rows: rows,
        day_of_week: "#{changeset.data.day_of_week}",
        closed: changeset.data.closed,
        errors: []
      )
    end
  end

  def create(conn, %{"child_care_hour" => hours, "location_id" => location_id}) do
    hours
    |> Map.put("location_id", location_id)
    |> ChildCareHours.create()
    |> case do
         {:ok, _hours} ->
           location =
             conn
             |> current_user()
             |> Location.get(location_id)

           conn
           |> put_flash(:success, "Child Care Hours created successfully.")
           |> redirect(to: team_location_child_care_hour_path(conn, :index, location.team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Child Care Hours failed to create")
           |> render_page("new.html", changeset, changeset.errors)
       end
  end

  def update(conn, %{"id" => id, "child_care_hour" => hours, "location_id" => location_id}) do
    hours
    |> Map.merge(%{"id" => id, "location_id" => location_id})
    |> ChildCareHours.update()
    |> case do
         {:ok, _hours} ->
           location =
             conn
             |> current_user()
             |> Location.get(location_id)

           conn
           |> put_flash(:success, "Child Care Hours updated successfully.")
           |> redirect(to: team_location_child_care_hour_path(conn, :index, location.team_id, location_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Child Care Hours failed to update")
           |> render_page("edit.html", changeset, changeset.errors)
       end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id, "location_id" => location_id}) do
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> ChildCareHours.update()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Child Care Hours deleted successfully.")
           |> redirect(to: team_location_child_care_hour_path(conn, :index, team_id, location_id))

         {:error, _changeset} ->
           conn
           |> put_flash(:error, "Child Care Hours failed to delete")
           |> render_page("index.html", team_id, location_id)
       end
  end

  defp render_page(conn, page, changeset, errors) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
