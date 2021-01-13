defmodule MainWeb.NormalHourController do
  use MainWeb.SecuredContoller

  alias Data.{NormalHours, Location}

  def index(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours = NormalHours.get_by_location_id(location_id)

    render(
      conn,
      "index.html",
      location: location,
      hours: hours,
      teams: teams(conn),
      changeset: NormalHours.get_changeset(),
      rows: [%{open_at: "", close_at: ""}]
    )
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours = NormalHours.get_by_location_id(location_id)

    hour = Enum.filter(hours, fn f -> f.id == id  end) |> List.first()

    rows = Enum.map(hour.times, fn time -> %{"open_at" => time.open_at, "close_at" => time.close_at} end)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- NormalHours.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        location: location,
        rows: rows,
        day_of_week: "#{changeset.data.day_of_week}",
        closed: changeset.data.closed,
        errors: [])
    end
  end

  def update(conn, %{"id" => id, "normal_hour" => hours, "team_id" => team_id, "location_id" => location_id}) do
    hours
    |> Map.merge(%{"id" => id, "location_id" => location_id})
    |> NormalHours.update()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Normal Hours updated successfully.")
           |> redirect(to: team_location_normal_hour_path(conn, :index, team_id, location_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Normal Hours failed to update")
           |> render_page("edit.html", changeset, changeset.errors)
       end
  end

  def delete(conn, %{"id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> NormalHours.update()
    |> case do
         {:ok, _hours} ->
           NormalHours.get_by_location_id(location_id)

           redirect(conn, to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/normal-hours")

         {:error, _changeset} ->
           NormalHours.get_by_location_id(location_id)

           redirect(conn, to: "/admin/teams/#{location.team_id}}/locations/#{location.id}/normal-hours")
       end
  end

  defp render_page(conn, page, changeset, errors) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
