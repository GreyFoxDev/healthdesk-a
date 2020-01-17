defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller

  alias Data.{Metrics, Disposition}

  def index(conn, %{"team_id" => team_id}) do
    dispositions = Disposition.count_by_team_id(team_id)

    render(conn, "index.html", metrics: [Metrics.team(team_id)], dispositions: dispositions, teams: teams(conn), team_id: team_id, location: nil)
  end

  def index(conn, _params) do
    current_user = current_user(conn)
    teams = teams(conn)

    if current_user.role == "admin" do
      metrics = Metrics.all_teams()
      dispositions = Disposition.count_all()

      render(conn, "index.html", metrics: metrics, dispositions: dispositions, teams: teams, location: nil, team_id: nil)
    else
      dispositions = Disposition.count_by_team_id(current_user.team_member.team_id)

      render(conn, "index.html", metrics: [Metrics.team(current_user.team_member.team_id)], dispositions: dispositions,teams: teams, location: nil, team_id: nil)
    end
  end

end
