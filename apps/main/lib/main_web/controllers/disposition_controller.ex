defmodule MainWeb.DispositionController do
  use MainWeb.SecuredContoller

  alias Data.{Disposition, Team}

  def index(conn, %{"team_id" => team_id}) do
    team =
      conn
      |> current_user()
      |> Team.get(team_id)

    dispositions =
      conn
      |> current_user()
      |> Disposition.get_by_team_id(team_id)

    render conn, "index.html", location: nil, dispositions: dispositions, team: team, teams: teams(conn), changeset: Disposition.get_changeset()
  end

  def create(conn, %{"disposition" => %{"disposition_name" => name} = disposition, "team_id" => team_id}) do
    case Disposition.get_by_team_and_name(team_id, name) do
      [] ->
        Map.put(disposition, "team_id", team_id)
        |> Disposition.create()
        |> case do
             {:ok, _hours} ->
               conn
               |> put_flash(:success, "Disposition created successfully.")
               |> redirect(to: team_disposition_path(conn, :index, team_id))
             {:error, changeset} ->
               conn
               |> put_flash(:error, "Disposition failed to create")
               |> render_page("index.html", changeset, changeset.errors)
           end
      _ ->
        conn
        |> put_flash(:error, "Disposition already exists")
        |> redirect(to: team_disposition_path(conn, :index, team_id))
    end
  end

  def delete(conn, %{"id" => id, "team_id" => team_id}) do
    %{
      "id" => id,
      "deleted_at" => DateTime.utc_now()
    }
    |> Disposition.update()
    |> case do
         {:ok, _hours} ->
           conn
           |> put_flash(:success, "Disposition deleted successfully.")
           |> redirect(to: team_disposition_path(conn, :index, team_id))

         {:error, _changeset} ->
           conn
           |> put_flash(:error, "Disposition failed to delete")
           |> render_page("index.html", team_id)
       end
  end

  defp render_page(conn, page, changeset, errors \\ []) do
    render(conn, page,
      changeset: changeset,
      errors: errors)
  end
end
