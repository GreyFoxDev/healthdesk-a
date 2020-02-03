defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller

  alias Data.{Metrics, Disposition, Location, TeamMember}

  def index(conn, %{"team_id" => team_id}) do
    current_user = current_user(conn)
    team_members = TeamMember.get_by_team_id(current_user, team_id)
    dispositions = Disposition.count_by_team_id(team_id)
    dispositions_per_day = Disposition.average_per_day_for_team(team_id)

    team_admin_count =
      team_members
      |> Enum.map(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()

    teammate_count =
      team_members
      |> Enum.map(&(&1.user.role == "teammate"))
      |> Enum.count()

    locations = Location.get_by_team_id(team_id)

    render(conn, "index.html",
      dispositions: dispositions,
      dispositions_per_day: dispositions_per_day,
      team_admin_count: team_admin_count,
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: team_id,
      location_id: current_user.team_member.location_id,
      location: nil)
  end

  def index(conn, %{"location_id" => location_id}) do
    current_user = current_user(conn)
    team_members = TeamMember.get_by_location_id(current_user, location_id)
    dispositions = 0
    dispositions_per_day = Disposition.average_per_day_for_location(location_id)

    team_admin_count =
      team_members
      |> Enum.map(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()

    teammate_count =
      team_members
      |> Enum.map(&(&1.user.role == "teammate"))
      |> Enum.count()

    locations = Location.get_by_team_id(current_user.team_member.team_id)

    render(conn, "index.html",
      dispositions: dispositions,
      dispositions_per_day: dispositions_per_day,
      team_admin_count: team_admin_count,
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: current_user.team_member.team_id,
      location_id: current_user.team_member.location_id,
      location: nil)
  end

  def index(conn, _params) do
    current_user = current_user(conn)
    teams = teams(conn)

    team_members = TeamMember.all()
    team_admin_count =
      team_members
      |> Enum.map(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()

    teammate_count =
      team_members
      |> Enum.map(&(&1.user.role == "teammate"))
      |> Enum.count()


    if current_user.role == "admin" do
      dispositions = Disposition.count_all()
      [dispositions_per_day] = Disposition.average_per_day()
      location_count = Location.all() |> Enum.count()

      render(conn, "index.html",
        metrics: [],
        dispositions: dispositions,
        dispositions_per_day: dispositions_per_day,
        teams: teams,
        team_admin_count: team_admin_count,
        teammate_count: teammate_count,
        location_count: location_count,
        location: nil,
        team_id: nil)
    else
      dispositions = Disposition.count_by_team_id(current_user.team_member.team_id)
      [dispositions_per_day] = Disposition.average_per_day_for_team(current_user.team_member.team_id)
      locations = Location.get_by_team_id(current_user, current_user.team_member.team_id)

      render(conn, "index.html",
        metrics: [],
        dispositions: dispositions,
        dispositions_per_day: dispositions_per_day,
        teams: teams,
        team_admin_count: team_admin_count,
        teammate_count: teammate_count,
        locations: locations,
        location_count: Enum.count(locations),
        location_id: current_user.team_member.location_id,
        location: nil,
        team_id: nil)
    end
  end

end
