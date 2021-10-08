defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller
  alias Data.{Campaign, Disposition, Location, TeamMember, ConversationDisposition, ConversationMessages, Appointments, Ticket}

  def index(conn, %{"team_id" => team_id} = params) do
    params=if(!is_nil(params["filters"])) do
      change_params(params)
    else
      params
    end
    current_user = current_user(conn)
    team_members = TeamMember.get_by_team_id(current_user, team_id)
    dispositions = Disposition.count_by(Map.merge(params, %{"team_id" => team_id}))
    appointments = Appointments.count_by_team_id(team_id, convert_values(params["to"]), convert_values(params["from"]))
    dispositions_per_day =
      case Disposition.average_per_day_for_team(params) do
        [result] -> result
        _ -> %{sessions_per_day: 0}
      end
    team_admin_count =
      team_members
      |> Enum.filter(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()
    teammate_count =
      team_members
      |> Enum.filter(&(&1.user.role == "teammate"))
      |> Enum.count()
    locations = Location.get_by_team_id(current_user, team_id)
    location_id = if current_user.team_member, do: current_user.team_member.location_id, else: nil
    response_time=ConversationMessages.count_by_team_id(team_id,params["from"] != "" && params["from"] || nil,params["to"] != "" && params["to"] || nil)
    campaigns = if location_id do
      Campaign.get_by_location_id(location_id)
    else
      locations
      |> Enum.map(fn(location) ->
        Campaign.get_by_location_id(location.id)
      end)
      |> List.flatten()
    end
    filter =
      case current_user do
        %{role: "team-admin"} -> %{"team_id" => current_user.team_member.team_id}
        %{role: "admin"} -> %{"team_member_id" => current_user.team_member && current_user.team_member.id}
        %{role: "teammate"} -> %{"tem_member_id" => current_user.team_member.id, location_id: current_user.team_member.location_id}
        _ -> %{}
      end
    params = Map.merge(params, filter)
    render(conn, "index.html",
      dispositions: dispositions,
      campaigns: campaigns,
      appointments: appointments,
      automated: calculate_percentage("Automated", dispositions),
      call_deflected: calculate_percentage("Call deflected", dispositions),
      dispositions_per_day: dispositions_per_day,
      web_totals: ConversationDisposition.count_channel_type_by_team_id("WEB", team_id, convert_values(params["to"]), convert_values(params["from"])),
      sms_totals: ConversationDisposition.count_channel_type_by_team_id("SMS", team_id, convert_values(params["to"]), convert_values(params["from"])),
      app_totals: ConversationDisposition.count_channel_type_by_team_id("APP", team_id, convert_values(params["to"]), convert_values(params["from"])),
      facebook_totals: ConversationDisposition.count_channel_type_by_team_id("FACEBOOK", team_id, convert_values(params["to"]), convert_values(params["from"])),
      email_totals: ConversationDisposition.count_channel_type_by_team_id("MAIL", team_id, convert_values(params["to"]), convert_values(params["from"])),
      response_time: response_time.median_response_time||0,
      team_admin_count: team_admin_count,
      tickets_count: Ticket.filter(params),
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: team_id,
      location_id: location_id,
      from: params["from"],
      to: params["to"],
      location: nil,

      location_ids: [])
  end
  def index(conn, %{"filters" => %{"location_ids" => location_ids}} = params) do
    params=if(!is_nil(params["filters"])) do
      change_params(params)
    else
      params
    end
    current_user = current_user(conn)
    team_members = TeamMember.get_by_location_ids(current_user, location_ids)
    dispositions = Disposition.count_by(params)
    appointments = Appointments.count_by_location_ids(location_ids, convert_values(params["to"]), convert_values(params["from"]))
    response_time = count_total_response_time(params)
    dispositions_per_day =
      case Disposition.average_per_day_for_locations(params) do
        [result] -> result
        _ -> %{sessions_per_day: 0}
      end
    team_admin_count =
      team_members
      |> Enum.filter(&(&1.user.role in ["location-admin", "team-admin"]))
      |> Enum.count()
    teammate_count =
      team_members
      |> Enum.filter(&(&1.user.role == "teammate"))
      |> Enum.count()
    locations = Location.get_by_team_id(current_user, current_user.team_member.team_id)
    filter =
      case current_user do
        %{role: "team-admin"} -> %{"team_id" => current_user.team_member.team_id, location_ids: location_ids}
        %{role: "admin"} -> %{"location_ids" => location_ids}
        %{role: "location-admin"} -> %{"location_ids" => location_ids}
        _ -> %{}
      end
    params=Map.merge(params, filter)
    render(conn, "index.html",
      dispositions: dispositions,
      automated: calculate_percentage("Automated", dispositions),
      call_deflected: calculate_percentage("Call deflected", dispositions),
      appointments: appointments,
      campaigns: Campaign.get_by_location_ids(location_ids),
      dispositions_per_day: dispositions_per_day,
      response_time: response_time,
      web_totals: ConversationDisposition.count_channel_type_by_location_ids("WEB", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      sms_totals: ConversationDisposition.count_channel_type_by_location_ids("SMS", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      app_totals: ConversationDisposition.count_channel_type_by_location_ids("APP", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      facebook_totals: ConversationDisposition.count_channel_type_by_location_ids("FACEBOOK", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      email_totals: ConversationDisposition.count_channel_type_by_location_ids("MAIL", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      team_admin_count: team_admin_count,
      tickets_count: Ticket.filter(params),
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: current_user.team_member.team_id,
      location_ids: location_ids,
      from: params["from"],
      to: params["to"],
      location: nil)
  end
  def index(conn, params) do
    params= if (!is_nil(params["filters"])), do: change_params(params), else: params
    current_user = current_user(conn)
    if current_user.role in ["team-admin", "teammate"] do
      index(conn, %{"team_id" => current_user.team_member.team_id})
    else
      teams = teams(conn)
      team_members = TeamMember.all()
      team_admin_count =
        team_members
        |> Enum.filter(&(&1.user.role in ["location-admin", "team-admin"]))
        |> Enum.count()
      teammate_count =
        team_members
        |> Enum.filter(&(&1.user.role == "teammate"))
        |> Enum.count()
      filter = case current_user do
        %{role: "team-admin"} -> %{"team_id" => current_user.team_member && current_user.team_member.team_id}
        %{role: "location-admin"} -> %{"team_member_id" => current_user.team_member && current_user.team_member.id}
        _ -> %{}
      end
      params= Map.merge(params, filter)
      if current_user.role == "admin" do
        dispositions = Disposition.count_all_by(params)
        appointments = Appointments.count_all(convert_values(params["to"]), convert_values(params["from"]))
        [dispositions_per_day] = Disposition.average_per_day(params)
        locations = Location.all()
        location_ids=Enum.map(locations, & &1.id)
#        response_times = Enum.map(locations, fn x -> ConversationMessages.count_by_location_id(x.id,params["to"] != "" && params["to"] || nil,params["from"] != "" && params["from"] || nil).median_response_time||0 end)
#        middle_index = response_times |> length() |> div(2)
#        response_time = response_times |> Enum.sort |> Enum.at(middle_index)

        response_time=count_total_response_time(%{"location_ids" => location_ids})
        campaigns =
        locations
        |> Enum.map(fn(location) -> Campaign.get_by_location_id(location.id)end) |> List.flatten()
        render(conn, "index.html",
          metrics: [],
          campaigns: campaigns,
          dispositions: dispositions,
          automated: calculate_percentage("Automated", dispositions),
          call_deflected: calculate_percentage("Call deflected", dispositions),
          appointments: appointments,
          dispositions_per_day: dispositions_per_day,
          response_time: response_time,
          web_totals: ConversationDisposition.count_all_by_channel_type("WEB", convert_values(params["to"]), convert_values(params["from"])),
          sms_totals: ConversationDisposition.count_all_by_channel_type("SMS", convert_values(params["to"]), convert_values(params["from"])),
          app_totals: ConversationDisposition.count_all_by_channel_type("APP", convert_values(params["to"]), convert_values(params["from"])),
          facebook_totals: ConversationDisposition.count_all_by_channel_type("FACEBOOK", convert_values(params["to"]), convert_values(params["from"])),
          email_totals: ConversationDisposition.count_all_by_channel_type("MAIL", convert_values(params["to"]), convert_values(params["from"])),
          teams: teams,
          team_admin_count: team_admin_count,
          tickets_count: Ticket.filter(params),
          teammate_count: teammate_count,
          location_count: Enum.count(locations),
          location: nil,
          from: params["from"],
          to: params["to"],
          location_ids: [],
          team_id: nil)
      else
        dispositions = Disposition.count_by(Map.merge(params, %{"team_id" => current_user.team_member.team_id}))
        appointments = Appointments.count_by_team_id(current_user.team_member.team_id, convert_values(params["to"]), convert_values(params["from"]))
        params = Map.merge(params, %{"team_id" => current_user.team_member.team_id})
        dispositions_per_day =
          case Disposition.average_per_day_for_team(params) do
            [result] -> result
            _ -> %{sessions_per_day: 0}
          end
        locations = Location.get_by_team_id(current_user, current_user.team_member.team_id)
        response_time=ConversationMessages.count_by_team_id(current_user.team_member.team_id,params["to"] != "" && params["to"] || nil,params["from"] != "" && params["from"] || nil)
        location_id = if current_user.team_member, do: current_user.team_member.location_id, else: nil
        campaigns = if location_id do
          Campaign.get_by_location_id(location_id)
        else
          locations
          |> Enum.map(fn(location) ->
            Campaign.get_by_location_id(location.id)
          end)
          |> List.flatten()
        end
        render(conn, "index.html",
          metrics: [],
          campaigns: campaigns,
          dispositions: dispositions,
          appointments: appointments,
          automated: calculate_percentage("Automated", dispositions),
          call_deflected: calculate_percentage("Call deflected", dispositions),
          dispositions_per_day: dispositions_per_day,
          response_time: response_time.median_response_time||0,
          web_totals: ConversationDisposition.count_channel_type_by_team_id("WEB", current_user.team_member.team_id, convert_values(params["to"]), convert_values(params["from"])),
          sms_totals: ConversationDisposition.count_channel_type_by_team_id("SMS", current_user.team_member.team_id, convert_values(params["to"]), convert_values(params["from"])),
          app_totals: ConversationDisposition.count_channel_type_by_team_id("APP", current_user.team_member.team_id, convert_values(params["to"]), convert_values(params["from"])),
          facebook_totals: ConversationDisposition.count_channel_type_by_team_id("FACEBOOK", current_user.team_member.team_id, convert_values(params["to"]), convert_values(params["from"])),
          email_totals: ConversationDisposition.count_channel_type_by_team_id("MAIL", current_user.team_member.team_id, convert_values(params["to"]), convert_values(params["from"])),
          teams: teams,
          team_admin_count: team_admin_count,
          tickets_count: Ticket.filter(params),
          teammate_count: teammate_count,
          locations: locations,
          location_count: Enum.count(locations),
          location_ids: [],
          location: nil,
          from: params["from"],
          to: params["to"],
          team_id: nil)
      end
    end
  end
  defp calculate_percentage(type, dispositions) do
    total =  Enum.map(dispositions, &(&1.count)) |> Enum.sum()

    call_transferred = (dispositions |> Enum.filter(&(&1.name == "Call Transferred")) |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    call_deflected =  (dispositions |> Enum.filter(&( &1.name == "Call Deflected"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    call_hung_up =  (dispositions |> Enum.filter(&(&1.name == "Call Hang Up"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    automated = (dispositions |> Enum.filter(&(&1.name == "Automated"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    case type do
      "Automated" ->
        test = dispositions |> Enum.count(&(&1.name == "GENERAL - Test")) || 0
        (automated / (if (total - (call_transferred + call_deflected + call_hung_up + test))== 0.0,do: 1,else: (total - (call_transferred + call_deflected + call_hung_up + test)))) * 100
      "Call deflected" ->

        (call_deflected  / (if (call_transferred + call_deflected + call_hung_up)==0.0,do: 1,else: (call_transferred + call_deflected + call_hung_up))) * 100
    end
  end

  defp change_params(params) do
    params=Map.merge(params, params["filters"])
    params=Map.delete(params, "filters")
  end
  defp count_total_response_time(%{"location_ids" => location_ids}= params) do
    response_times = Enum.map(location_ids, fn location_id -> ConversationMessages.count_by_location_id(location_id,params["from"] != "" && params["from"] || nil, params["to"] != "" && params["to"] || nil).median_response_time||0 end)
    Enum.sum(response_times)|> div(length(response_times))
  end
  defp convert_values(value) do
    case value do
      "" -> nil
      _-> value
    end
  end
end