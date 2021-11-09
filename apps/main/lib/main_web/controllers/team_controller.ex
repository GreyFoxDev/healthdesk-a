defmodule MainWeb.TeamController do
  use MainWeb.SecuredContoller

  alias Data.{Disposition, Team, Location}

  def index(conn, _params) do
    render conn, "index.html", teams: teams(conn), location: nil, tab: "knowledge"
  end

  def show(conn, %{"id" => id}) do
    team =
      conn
      |> current_user()
      |> Team.get(id)

    render conn, "show.json", data: team
  end

  def new(conn, _params) do

    render(conn, "new.html",
      changeset: Team.get_changeset(),
      location: nil,
      teams: teams(conn),
      bot_id: Application.get_env(:wit_client, :access_token),
      errors: [])
  end

  def edit(conn, %{"id" => id}) do
    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Team.get_changeset(id, user) do

      render(conn, "edit.html",
        changeset: changeset,
        location: nil,
        teams: teams(conn),
        errors: [])
    end
  end

  def create(conn, %{"team" => team}) do
    case Team.create(team) do
      {:ok, team} ->
        %{"disposition_name" => "Automated"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "Call Hang Up"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "Call Deflected"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "Call Transferred"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "SMS Unsubscribe"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "Missed Call Texted"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "thanks"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "imessage"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "greetings"} |> Map.put("team_id", team.id)|> Disposition.create()
        %{"disposition_name" => "New Leads"} |> Map.put("team_id", team.id)|> Disposition.create()
        conn
        |> put_flash(:success, "Team created successfully.")
        |> redirect(to: team_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Team failed to create")
        |> render_page("new.html", changeset, changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "team" => team}) do
    locations = Location.all
    Enum.each(locations, fn location -> Location.update(location.id, %{phone_number: team["phone_number"]}) end)
    case Team.update(id, team) do
      {:ok, _team} ->
        conn
        |> put_flash(:success, "Team updated successfully.")
        |> redirect(to: team_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Team failed to update")
        |> render_page("edit.html", changeset, changeset.errors)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Team.update(id, %{"deleted_at" => DateTime.utc_now()}) do
      {:ok, _team} ->
        conn
        |> put_flash(:success, "Team deleted successfully.")
        |> redirect(to: team_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Team failed to delete")
        |> render("index.html")
    end
  end

  defp render_page(conn, page, changeset, errors) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
