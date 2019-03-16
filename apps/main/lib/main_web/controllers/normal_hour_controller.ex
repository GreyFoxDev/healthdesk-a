defmodule MainWeb.NormalHourController do
  use MainWeb.SecuredContoller

  alias Data.{NormalHours, Location}

  def index(conn, %{"location_id" => location_id} = params) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    hours =
      conn
      |> current_user()
      |> NormalHours.all(location_id)

    render conn, "index.html", location: location, hours: hours, teams: teams(conn), changeset: NormalHours.get_changeset()
  end

  def new(conn, %{"location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    render(conn, "new.html",
      changeset: NormalHours.get_changeset(),
      location: location,
      errors: [])
  end

  def edit(conn, %{"id" => id, "location_id" => location_id}) do
    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- NormalHours.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        location: location,
        errors: [])
    end
  end

  def create(conn, %{"normal_hour" => hours, "team_id" => team_id, "location_id" => location_id} = params) do
    hours
    |> Map.put("location_id", location_id)
    |> NormalHours.create()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Normal Hours created successfully.")
           |> redirect(to: team_location_normal_hour_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Normal Hours failed to create")
           |> render_page("new.html", changeset, changeset.errors)
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

  def delete(conn, %{"id" => id, "team_id" => team_id, "location_id" => location_id}) do
    %{"id" => id, "deleted_at" => DateTime.utc_now()}
    |> NormalHours.update()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Normal Hours deleted successfully.")
           |> redirect(to: team_location_normal_hour_path(conn, :index, team_id, location_id))

         {:error, changeset} ->
           conn
           |> put_flash(:error, "Normal Hours failed to delete")
           |> render_page("index.html", team_id, location_id)
       end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
