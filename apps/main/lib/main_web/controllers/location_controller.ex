defmodule MainWeb.LocationController do
  use MainWeb.SecuredContoller

  alias Data.{Location, Commands.Team}

  def index(conn, %{"team_id" => team_id} = params) do
    {:ok, team} =
      conn
      |> current_user()
      |> Team.get_team_locations(team_id)

    render conn, "index.html",
      location: nil,
      locations: team.locations,
      team: team,
      teams: teams(conn)
  end

  def show(conn, %{"id" => id}) do
    location =
      conn
      |> current_user()
      |> Location.get(id)

    render conn, "show.json", data: location
  end

  def new(conn, %{"team_id" => team_id}) do
    render(conn, "new.html",
      changeset: Location.get_changeset(),
      team_id: team_id,
      location: nil,
      teams: teams(conn),
      errors: [])
  end

  def edit(conn, %{"id" => id, "team_id" => team_id}) do
    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Location.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        team_id: team_id,
        teams: teams(conn),
        location: changeset.data,
        errors: [])
    end
  end

  def create(conn, %{"location" => location, "team_id" => team_id} = params) do
    location
    |> Map.put("team_id", team_id)
    |> Location.create()
    |> case do
         %Data.Schema.Location{} ->
          conn
           |> put_flash(:success, "Location created successfully.")
           |> redirect(to: team_location_path(conn, :index, team_id))
         {:error, changeset} ->
           conn
           |> put_flash(:error, "Location failed to create")
           |> render_page("new.html", changeset, changeset.errors)
       end
  end

  def update(conn, %{"id" => id, "location" => location, "team_id" => team_id}) do
    location = Map.put(location, "team_id", team_id)

    case Location.update(id, location) do
      %Data.Schema.Location{} ->
        conn
        |> put_flash(:success, "Location updated successfully.")
        |> redirect(to: team_location_path(conn, :index, team_id))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Location failed to update")
        |> render_page("edit.html", changeset, changeset.errors)
    end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    case Location.update(id, %{"deleted_at" => DateTime.utc_now()}) do
      {:ok, _location} ->
        conn
        |> put_flash(:success, "Location deleted successfully.")
        |> redirect(to: team_location_path(conn, :index, team_id))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Location failed to delete")
        |> render("index.html", team_id)
    end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
