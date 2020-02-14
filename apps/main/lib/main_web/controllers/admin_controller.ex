defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller

  alias Data.{Disposition, Location, TeamMember, ConversationDisposition}

  def index(conn, %{"team_id" => team_id}) do
    current_user = current_user(conn)
    team_members = TeamMember.get_by_team_id(current_user, team_id)
    dispositions = Disposition.count_by_team_id(team_id)
    dispositions_per_day =
      case Disposition.average_per_day_for_team(team_id) do
        [result] -> result
        _ -> %{sessions_per_day: 0}
      end

    team_admin_count =
      team_members
      |> Enum.map(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()

    teammate_count =
      team_members
      |> Enum.map(&(&1.user.role == "teammate"))
      |> Enum.count()

    locations = Location.get_by_team_id(current_user, team_id)

    location_id = if current_user.team_member, do: current_user.team_member.location_id, else: nil

    render(conn, "index.html",
      dispositions: dispositions,
      dispositions_per_day: dispositions_per_day,
      web_totals: team_totals_by_channel("WEB", team_id),
      sms_totals: team_totals_by_channel("SMS", team_id),
      facebook_totals: team_totals_by_channel("FACEBOOK", team_id),
      team_admin_count: team_admin_count,
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: team_id,
      location_id: location_id,
      location: nil)
  end

  def index(conn, %{"location_id" => location_id}) do
    current_user = current_user(conn)
    team_members = TeamMember.get_by_location_id(current_user, location_id)
    dispositions = Disposition.count_by_location_id(location_id)
    dispositions_per_day =
      case Disposition.average_per_day_for_location(location_id) do
        [result] -> result
        _ -> %{sessions_per_day: 0}
      end

    team_admin_count =
      team_members
      |> Enum.map(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()

    teammate_count =
      team_members
      |> Enum.map(&(&1.user.role == "teammate"))
      |> Enum.count()

    locations = Location.get_by_team_id(current_user, current_user.team_member.team_id)

    render(conn, "index.html",
      dispositions: dispositions,
      dispositions_per_day: dispositions_per_day,
      web_totals: location_totals_by_channel("WEB", location_id),
      sms_totals: location_totals_by_channel("SMS", location_id),
      facebook_totals: location_totals_by_channel("FACEBOOK", location_id),
      team_admin_count: team_admin_count,
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: current_user.team_member.team_id,
      location_id: location_id,
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
        web_totals: totals_by_channel("WEB"),
        sms_totals: totals_by_channel("SMS"),
        facebook_totals: totals_by_channel("FACEBOOK"),
        teams: teams,
        team_admin_count: team_admin_count,
        teammate_count: teammate_count,
        location_count: location_count,
        location: nil,
        location_id: nil,
        team_id: nil)
    else
      dispositions = Disposition.count_by_team_id(current_user.team_member.team_id)
      dispositions_per_day =
        case Disposition.average_per_day_for_team(current_user.team_member.team_id) do
          [result] -> result
          _ -> %{sessions_per_day: 0}
        end
      locations = Location.get_by_team_id(current_user, current_user.team_member.team_id)

      location_id = if current_user.team_member, do: current_user.team_member.location_id, else: nil

      render(conn, "index.html",
        metrics: [],
        dispositions: dispositions,
        dispositions_per_day: dispositions_per_day,
        web_totals: team_totals_by_channel("WEB", current_user.team_member.team_id),
        sms_totals: team_totals_by_channel("SMS", current_user.team_member.team_id),
        facebook_totals: team_totals_by_channel("FACEBOOK", current_user.team_member.team_id),
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

  defp totals_by_channel(channel_type) do
    results = ConversationDisposition.count_all_by_channel_type(channel_type)
    sum(results)
  end

  defp team_totals_by_channel(channel_type, team_id) do
    results = ConversationDisposition.count_channel_type_by_team_id(channel_type, team_id)
    sum(results)
  end

  defp location_totals_by_channel(channel_type, location_id) do
    results = ConversationDisposition.count_channel_type_by_location_id(channel_type, location_id)
    sum(results)
  end

  defp sum(results) do
    results
    |> Enum.map(&(&1.disposition_count))
    |> Enum.sum()
  end
end
