defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller

  alias Data.Metrics

  def index(conn, %{"team_id" => team_id}) do
    render(conn, "index.html", metrics: [Metrics.team(team_id)], teams: teams(conn))
  end

  def index(conn, _params) do
    current_user = current_user(conn)
    teams = teams(conn)

    if current_user.role == "admin" do
      render(conn, "index.html", metrics: Metrics.all_teams(), teams: teams, location: nil)
    else
      render(conn, "index.html", metrics: [Metrics.team(current_user.team_member.team_id)], teams: teams, location: nil)
    end
  end

end
