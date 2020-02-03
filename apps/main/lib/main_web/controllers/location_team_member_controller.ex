defmodule MainWeb.LocationTeamMemberController do
  use MainWeb.SecuredContoller

  alias Data.{Location, Team, TeamMember}

  def index(conn, %{"team_id" => team_id, "location_id" => location_id}) do
    team =
      conn
      |> current_user()
      |> Team.get(team_id)

    location =
      conn
      |> current_user()
      |> Location.get(location_id)

    team_members =
      conn
      |> current_user()
      |> TeamMember.get_by_team_id(team_id)

    location_team_members =
      conn
      |> current_user()
      |> TeamMember.get_by_location_id(location_id)

    render conn, "index.html",
      location: location,
      team: team,
      team_members: team_members,
      location_team_members: location_team_members,
      teams: teams(conn)
  end
end
