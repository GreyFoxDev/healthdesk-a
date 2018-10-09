defmodule MainWeb.TeamController do
  use MainWeb.SecuredContoller

  alias Data.Team

  def index(conn, _params) do
    teams =
      conn
      |> current_user()
      |> Team.all()

    render conn, "index.html", teams: teams
  end

  def show(conn, %{"id" => id}) do
    team =
      conn
      |> current_user()
      |> Team.get(id)

    render conn, "show.json", data: team
  end

  def new(conn, _params),
    do: render_page conn, "new.html", Team.get_changeset()

  def edit(conn, %{"id" => id}) do
    with %Data.Schema.User{} = user <- current_user(conn),
         {:ok, changeset} <- Team.get_changeset(id, user) do
      render_page conn, "edit.html", changeset
    end
  end

  def create(conn, %{"team" => team}) do
    case Team.create(team) do
      {:ok, _team} ->
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
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Team failed to delete")
        |> render("index.html")
    end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
