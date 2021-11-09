defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller
  alias Data.{Campaign, Disposition, Location, Team ,TeamMember, ConversationDisposition, ConversationMessages, Appointments, Ticket, Member}

  @new_leads [
  "salesQuestion",
  "getTour",
  "getTrialPass",
  "getGuestPass",
  "getMonthPass",
  "getDayPass",
  "getWeekPass",
  ]
#  def index(conn, %{"team_id" => team_id} = params) do
#    IO.inspect("++++++++++++++inside team_id++++++++++++++++")
#    params=if(!is_nil(params["filters"])) do
#      change_params(params)
#    else
#      params
#    end
#    current_user = current_user(conn)
#    team_members = TeamMember.get_by_team_id(current_user, team_id)
#    dispositions = Disposition.count_by(Map.merge(params, %{"team_id" => team_id}))
#    automated = Data.IntentUsage.count_intent_by(Map.merge(params, %{"team_id" => team_id}))
#    appointments = Appointments.count_by_team_id(team_id, convert_values(params["to"]), convert_values(params["from"]))
#    dispositions_per_day =
#      case Disposition.average_per_day_for_team(params) do
#        [result] -> result
#        _ -> %{sessions_per_day: 0}
#      end
#    team_admin_count =
#      team_members
#      |> Enum.filter(&(&1.user.role in ["location-admin", "team-admin"]))
#      |> Enum.count()
#    teammate_count =
#      team_members
#      |> Enum.filter(&(&1.user.role == "teammate"))
#      |> Enum.count()
#    locations = Location.get_by_team_id(current_user, team_id)
#    location_ids=Enum.map(locations, fn location-> location.id end)
#    location_id = if current_user.team_member, do: current_user.team_member.location_id, else: nil
#    response_time=ConversationMessages.count_by_location_id(location_ids,params["from"] != "" && params["from"] || nil,params["to"] != "" && params["to"] || nil)
#    campaigns = if location_id do
#      Campaign.get_by_location_id(location_id)
#    else
#      locations
#      |> Enum.map(fn(location) ->
#        Campaign.get_by_location_id(location.id)
#      end)
#      |> List.flatten()
#    end
#    filter =
#      case current_user do
#        %{role: "team-admin"} -> %{"team_id" => current_user.team_member.team_id}
#        %{role: "admin"} -> %{"team_member_id" => current_user.team_member && current_user.team_member.id}
#        %{role: "teammate"} -> %{"tem_member_id" => current_user.team_member.id, location_id: current_user.team_member.location_id}
#        _ -> %{}
#      end
#    params = Map.merge(params, filter)
#    render(conn, "index.html",
#      dispositions: dispositions,
#      campaigns: campaigns,
#      appointments: appointments,
#      automated_data: automated,
#      automated: calculate_automated_percentage(dispositions, automated),
#      call_deflected: calculate_percentage("Call deflected", dispositions),
#      dispositions_per_day: dispositions_per_day,
#      web_totals: ConversationDisposition.count_channel_type_by_team_id("WEB", team_id, convert_values(params["to"]), convert_values(params["from"])),
#      sms_totals: ConversationDisposition.count_channel_type_by_team_id("SMS", team_id, convert_values(params["to"]), convert_values(params["from"])),
#      app_totals: ConversationDisposition.count_channel_type_by_team_id("APP", team_id, convert_values(params["to"]), convert_values(params["from"])),
#      facebook_totals: ConversationDisposition.count_channel_type_by_team_id("FACEBOOK", team_id, convert_values(params["to"]), convert_values(params["from"])),
#      email_totals: ConversationDisposition.count_channel_type_by_team_id("MAIL", team_id, convert_values(params["to"]), convert_values(params["from"])),
#      call_totals: ConversationDisposition.count_channel_type_by_team_id("CALL", team_id, convert_values(params["to"]), convert_values(params["from"])),
#      response_time: response_time.median_response_time||0,
#      team_admin_count: team_admin_count,
#      tickets_count: Ticket.filter(params),
#      teammate_count: teammate_count,
#      locations: locations,
#      location_count: Enum.count(locations),
#      teams: teams(conn),
#      team_id: team_id,
#      location_id: location_id,
#      from: params["from"],
#      to: params["to"],
#      location: nil,
#
#      location_ids: [],
#      role: current_user.role)
#  end
  def index(conn, %{"filters" => %{"location_ids" => location_ids}} = params) do
    params=if(!is_nil(params["filters"])) do
      change_params(params)
    else
      params
    end
    current_user = current_user(conn)
    team_members = TeamMember.get_by_location_ids(current_user, location_ids)
    dispositions = Disposition.count_by(params)
    to = Data.Disposition.convert_string_to_date(params["to"])
    from = Data.Disposition.convert_string_to_date(params["from"])
    %{bar_graph_data: bar_graph_data, start_date: bar_graph_start_date}=get_bar_graph_data(dispositions, to, from)
    automated = Data.IntentUsage.count_intent_by(params)
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
    locations = Location.get_locations_by_ids(current_user, location_ids)
    filter =
      case current_user do
        %{role: "team-admin"} -> %{"team_id" => current_user.team_member.team_id, location_ids: location_ids}
        %{role: "admin"} -> %{"location_ids" => location_ids}
        %{role: "location-admin"} -> %{"location_ids" => location_ids}
        _ -> %{}
      end
      team_id =
      if (current_user.role == "admin") do
        Team.get_by_location_id(List.first(location_ids)).id
      else
          case current_user.team_member do
            nil -> params["team_id"]
            _ -> current_user.team_member.team_id
          end

      end

    locations=
    if(current_user.role == "admin") do
      Location.get_by_team_id(%{role: current_user.role},team_id)
      else
      Location.get_by_team_id(current_user, team_id)
    end

    call_deflect_response = Data.ConversationCall.get_response_after_call(["Call deflected","Call Deflected"], params["to"], params["from"], location_ids)
    missed_call_response = Data.ConversationCall.get_response_after_call(["Missed Call Texted"],params["to"], params["from"], location_ids)
    missed_call_texted = calculate_percentage("Missed Call Texted", dispositions)
    params=Map.merge(params, filter)

    web_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("WEB", location_ids, convert_values(params["to"]), convert_values(params["from"]))
    oldest = List.first(Enum.min_by(web_totals_by_day, fn x -> List.first(x) end, Date))
    web_totals_by_day=Enum.map(web_totals_by_day, fn x -> List.last(x) end)
    sms_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("SMS", location_ids, convert_values(params["to"]), convert_values(params["from"]))
    sms_totals_by_day=Enum.map(sms_totals_by_day, fn x -> List.last(x) end)
    app_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("APP", location_ids, convert_values(params["to"]), convert_values(params["from"]))
    app_totals_by_day=Enum.map(app_totals_by_day, fn x -> List.last(x) end)
    facebook_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("FACEBOOK", location_ids, convert_values(params["to"]), convert_values(params["from"]))
    facebook_totals_by_day=Enum.map(facebook_totals_by_day, fn x -> List.last(x) end)
    mail_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("MAIL", location_ids, convert_values(params["to"]), convert_values(params["from"]))
    mail_totals_by_day=Enum.map(mail_totals_by_day, fn x -> List.last(x) end)
    call_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("CALL", location_ids, convert_values(params["to"]), convert_values(params["from"]))
    call_totals_by_day=Enum.map(call_totals_by_day, fn x -> List.last(x) end)

    new_user = Data.Member.count_new_member_by(params["to"], params["from"], location_ids)
    active_user= Data.Member.count_active_user_by(location_ids)

    render(conn, "index.html",
      dispositions: dispositions,
      bar_graph: bar_graph_data,
      bar_graph_start_date: bar_graph_start_date,
      automated_data: automated,
      automated: calculate_automated_percentage(dispositions, automated),
      call_deflected: calculate_percentage("Call deflected", dispositions),
      call_deflect_response: call_deflect_response,
      intent_after_call_deflect: Data.IntentUsage.get_intent_count_after_call_disposition(["Call deflected","Call Deflected"], params["to"], params["from"], location_ids),
      new_leads_after_call_deflect: Data.IntentUsage.get_leads_count_after_call_disposition(["Call deflected","Call Deflected"], params["to"], params["from"], location_ids),
      call_deflect_response_rate: calculate_response_rate_after_call(["Call deflected","Call Deflected"],dispositions, call_deflect_response),
      missed_call_texted: missed_call_texted.total_percentage,
      missed_call_response: missed_call_response,
      intent_after_missed_call: Data.IntentUsage.get_intent_count_after_call_disposition(["Missed Call Texted"], params["to"], params["from"], location_ids),
      new_leads_after_missed_call: Data.IntentUsage.get_leads_count_after_call_disposition(["Missed Call Texted"], params["to"], params["from"], location_ids),
      missed_call_response_rate: calculate_response_rate_after_call(["Missed Call Texted"],dispositions, missed_call_response),
      missed_call_rate: missed_call_texted.missed_call_rate,
      appointments: appointments,
      campaigns: Campaign.get_by_location_ids(location_ids),
      dispositions_per_day: dispositions_per_day,
      response_time: response_time,
#      web_total_for_days: ConversationDisposition.channel_type_by_location_ids_and_days("WEB", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      web_totals_by_day: web_totals_by_day,
      app_totals_by_day: app_totals_by_day,
      sms_totals_by_day: sms_totals_by_day,
      facebook_totals_by_day: facebook_totals_by_day,
      mail_totals_by_day: mail_totals_by_day,
      call_totals_by_day: call_totals_by_day,
      avg_totals_by_day: get_average_for_line_graph(web_totals_by_day, sms_totals_by_day, app_totals_by_day, facebook_totals_by_day, mail_totals_by_day, call_totals_by_day),
      line_graph_start_date: Date.to_iso8601(oldest),
      web_totals: ConversationDisposition.count_channel_type_by_location_ids("WEB", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      sms_totals: ConversationDisposition.count_channel_type_by_location_ids("SMS", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      app_totals: ConversationDisposition.count_channel_type_by_location_ids("APP", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      facebook_totals: ConversationDisposition.count_channel_type_by_location_ids("FACEBOOK", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      email_totals: ConversationDisposition.count_channel_type_by_location_ids("MAIL", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      call_totals: ConversationDisposition.count_channel_type_by_location_ids("CALL", location_ids, convert_values(params["to"]), convert_values(params["from"])),
      team_admin_count: team_admin_count,
      tickets_count: Ticket.filter(params),
      teammate_count: teammate_count,
      locations: locations,
      location_count: Enum.count(locations),
      teams: teams(conn),
      team_id: team_id,
      location_ids: location_ids,
      from: params["from"],
      to: params["to"],
      location: nil,
      role: current_user.role,
      new_leads: Enum.filter(dispositions, &(&1.name == "New Lead")) |> Enum.map(&(&1.count)) |> Enum.sum() || 0,
      new_leads_data: Enum.filter(automated, &(&1.intent in @new_leads)),
      new_user: new_user,
      active_user: active_user
    )
  end
  def index(conn, params) do

    params= if (!is_nil(params["filters"])), do: change_params(params), else: params
    current_user = current_user(conn)
    if current_user.role in ["team-admin", "teammate"] do
      location_ids = Location.get_location_ids_by_team_id(current_user, current_user.team_member.team_id)
      index(conn, %{"filters" => %{"from" => "","location_ids" => location_ids, "to" => ""}})
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

        if (!is_nil(params["team_id"])) do
          location_ids = Location.get_location_ids_by_team_id(current_user, params["team_id"])
          index(conn, %{"filters" => %{"from" => params["from"],"location_ids" => location_ids, "to" =>params["to"]}, "team_id" => params["team_id"]})

        end
        dispositions = Disposition.count_all_by(params)
        automated = Data.IntentUsage.count_intent_by(params)
        appointments = Appointments.count_all(convert_values(params["to"]), convert_values(params["from"]))
        [dispositions_per_day] = Disposition.average_per_day(params)
        locations = Location.all()
        location_ids=Enum.map(locations, & &1.id)
        call_deflect_response = Data.ConversationCall.get_response_after_call(["Call deflected","Call Deflected"], params["to"], params["from"])
        missed_call_response = Data.ConversationCall.get_response_after_call(["Missed Call Texted"], params["to"], params["from"])
        missed_call_texted = calculate_percentage("Missed Call Texted", dispositions)

        #        response_times = Enum.map(locations, fn x -> ConversationMessages.count_by_location_id(x.id,params["to"] != "" && params["to"] || nil,params["from"] != "" && params["from"] || nil).median_response_time||0 end)
#        middle_index = response_times |> length() |> div(2)
#        response_time = response_times |> Enum.sort |> Enum.at(middle_index)

        response_time=count_total_response_time(%{"location_ids" => location_ids})
        campaigns =
        locations
        |> Enum.map(fn(location) -> Campaign.get_by_location_id(location.id)end) |> List.flatten()

        web_totals_by_day=ConversationDisposition.count_all_by_channel_type_and_days("WEB", convert_values(params["to"]), convert_values(params["from"]))
        oldest = List.first(Enum.min_by(web_totals_by_day, fn x -> List.first(x) end, Date))
        web_totals_by_day=Enum.map(web_totals_by_day, fn x -> List.last(x) end)
        sms_totals_by_day=ConversationDisposition.count_all_by_channel_type_and_days("SMS", convert_values(params["to"]), convert_values(params["from"]))
        sms_totals_by_day=Enum.map(sms_totals_by_day, fn x -> List.last(x) end)
        app_totals_by_day=ConversationDisposition.count_all_by_channel_type_and_days("APP", convert_values(params["to"]), convert_values(params["from"]))
        app_totals_by_day=Enum.map(app_totals_by_day, fn x -> List.last(x) end)
        facebook_totals_by_day=ConversationDisposition.count_all_by_channel_type_and_days("FACEBOOK", convert_values(params["to"]), convert_values(params["from"]))
        facebook_totals_by_day=Enum.map(facebook_totals_by_day, fn x -> List.last(x) end)
        mail_totals_by_day=ConversationDisposition.count_all_by_channel_type_and_days("MAIL", convert_values(params["to"]), convert_values(params["from"]))
        mail_totals_by_day=Enum.map(mail_totals_by_day, fn x -> List.last(x) end)
        call_totals_by_day=ConversationDisposition.count_all_by_channel_type_and_days("CALL", convert_values(params["to"]), convert_values(params["from"]))
        call_totals_by_day=Enum.map(call_totals_by_day, fn x -> List.last(x) end)
        to = Data.Disposition.convert_string_to_date(params["to"])|> IO.inspect(label: "to datae")
        from = Data.Disposition.convert_string_to_date(params["from"]) |> IO.inspect(label: "from date")
        %{bar_graph_data: bar_graph_data, start_date: bar_graph_start_date}=get_bar_graph_data(dispositions, to, from)

        new_user = Data.Member.count_all_new_member(params["to"], params["from"])
        active_user = Data.Member.count_active_user()

        render(conn, "index.html",
          metrics: [],
          campaigns: campaigns,
          dispositions: dispositions,
          bar_graph: bar_graph_data,
          bar_graph_start_date: bar_graph_start_date,
          automated_data: automated,
          automated: calculate_automated_percentage(dispositions ,automated),
          call_deflected: calculate_percentage("Call deflected", dispositions),
          call_deflect_response: call_deflect_response,
          intent_after_call_deflect: Data.IntentUsage.get_intent_count_after_call_disposition(["Call deflected","Call Deflected"], params["to"], params["from"]),
          new_leads_after_call_deflect: Data.IntentUsage.get_leads_count_after_call_disposition(["Call deflected","Call Deflected"], params["to"], params["from"]),
          call_deflect_response_rate: calculate_response_rate_after_call(["Call deflected","Call Deflected"],dispositions ,call_deflect_response),
          missed_call_texted: missed_call_texted.total_percentage,
          missed_call_response: missed_call_response,
          intent_after_missed_call: Data.IntentUsage.get_intent_count_after_call_disposition(["Missed Call Texted"], params["to"], params["from"]),
          new_leads_after_missed_call: Data.IntentUsage.get_leads_count_after_call_disposition(["Missed Call Texted"], params["to"], params["from"]),
          missed_call_response_rate: calculate_response_rate_after_call(["Missed Call Texted"],dispositions ,missed_call_response),
          missed_call_rate: missed_call_texted.missed_call_rate,
          appointments: appointments,
          dispositions_per_day: dispositions_per_day,
          response_time: response_time,
          web_totals_by_day: web_totals_by_day,
          app_totals_by_day: app_totals_by_day,
          sms_totals_by_day: sms_totals_by_day,
          facebook_totals_by_day: facebook_totals_by_day,
          mail_totals_by_day: mail_totals_by_day,
          call_totals_by_day: call_totals_by_day,
          avg_totals_by_day: get_average_for_line_graph(web_totals_by_day, sms_totals_by_day, app_totals_by_day, facebook_totals_by_day, mail_totals_by_day, call_totals_by_day),
          line_graph_start_date: Date.to_iso8601(oldest),
          web_totals: ConversationDisposition.count_all_by_channel_type("WEB", convert_values(params["to"]), convert_values(params["from"])),
          sms_totals: ConversationDisposition.count_all_by_channel_type("SMS", convert_values(params["to"]), convert_values(params["from"])),
          app_totals: ConversationDisposition.count_all_by_channel_type("APP", convert_values(params["to"]), convert_values(params["from"])),
          facebook_totals: ConversationDisposition.count_all_by_channel_type("FACEBOOK", convert_values(params["to"]), convert_values(params["from"])),
          email_totals: ConversationDisposition.count_all_by_channel_type("MAIL", convert_values(params["to"]), convert_values(params["from"])),
          call_totals: ConversationDisposition.count_all_by_channel_type("CALL", convert_values(params["to"]), convert_values(params["from"])),
          teams: teams,
          team_admin_count: team_admin_count,
          tickets_count: Ticket.filter(params),
          teammate_count: teammate_count,
          location_count: Enum.count(locations),
          locations: nil,
          from: params["from"],
          to: params["to"],
          location_ids: [],
          team_id: TeamMember.get_by_user_id(%{role: current_user.role},current_user.id),
          role: current_user.role,
          new_leads: Enum.filter(dispositions, &(&1.name == "New Lead")) |> Enum.map(&(&1.count)) |> Enum.sum() || 0,
          new_leads_data: Enum.filter(automated, &(&1.intent in @new_leads)),
          new_user: new_user,
          active_user: active_user
        )
      else
        location_ids = Location.get_location_ids_by_team_id(current_user, current_user.team_member.team_id)
        dispositions = Disposition.count_by(%{"location_ids" => location_ids, "to" => convert_values(params["filter"]["to"]), "from" => convert_values(params["filter"]["from"])})
        automated = Data.IntentUsage.count_intent_by(%{"location_ids" => location_ids, "to" => convert_values(params["filter"]["to"]), "from" => convert_values(params["filter"]["from"])})
        appointments = Appointments.count_by_location_ids(location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"]))
        params = Map.merge(params, %{"location_ids" => location_ids})
        dispositions_per_day =
          case Disposition.average_per_day_for_locations(params) do
            [result] -> result
            _ -> %{sessions_per_day: 0}
          end
        locations = Location.get_by_team_id(current_user, current_user.team_member.team_id)
        response_time=ConversationMessages.count_by_location_id(location_ids,convert_values(params["filter"]["to"]),convert_values(params["filter"]["from"]))
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

        web_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("WEB", location_ids, convert_values(params["to"]), convert_values(params["from"]))
        web_totals_by_day=Enum.map(web_totals_by_day, fn x -> List.last(x) end)
        sms_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("SMS", location_ids, convert_values(params["to"]), convert_values(params["from"]))
        sms_totals_by_day=Enum.map(sms_totals_by_day, fn x -> List.last(x) end)
        app_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("APP", location_ids, convert_values(params["to"]), convert_values(params["from"]))
        app_totals_by_day=Enum.map(app_totals_by_day, fn x -> List.last(x) end)
        facebook_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("FACEBOOK", location_ids, convert_values(params["to"]), convert_values(params["from"]))
        facebook_totals_by_day=Enum.map(facebook_totals_by_day, fn x -> List.last(x) end)
        mail_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("MAIL", location_ids, convert_values(params["to"]), convert_values(params["from"]))
        mail_totals_by_day=Enum.map(mail_totals_by_day, fn x -> List.last(x) end)
        call_totals_by_day=ConversationDisposition.channel_type_by_location_ids_and_days("CALL", location_ids, convert_values(params["to"]), convert_values(params["from"]))
        call_totals_by_day=Enum.map(call_totals_by_day, fn x -> List.last(x) end)

        call_deflect_response = Data.ConversationCall.get_response_after_call(["Call deflected","Call Deflected"], params["to"], params["from"], location_ids)
        missed_call_response = Data.ConversationCall.get_response_after_call(["Missed Call Texted"],params["to"], params["from"], location_ids)
        missed_call_texted = calculate_percentage("Missed Call Texted", dispositions)
        to = Data.Disposition.convert_string_to_date(params["to"])
        from = Data.Disposition.convert_string_to_date(params["from"])
        %{bar_graph_data: bar_graph_data, start_date: bar_graph_start_date}=get_bar_graph_data(dispositions, to, from)

        new_user = Data.Member.count_new_member_by(params["to"], params["from"], location_ids)
        active_user= Data.Member.count_active_user_by(location_ids)
        render(conn, "index.html",
          metrics: [],
          campaigns: campaigns,
          dispositions: dispositions,
          bar_graph: bar_graph_data,
          bar_graph_start_date: bar_graph_start_date,
          appointments: appointments,
          automated_data: automated,
          automated: calculate_automated_percentage(dispositions, automated),
          call_deflected: calculate_percentage("Call deflected", dispositions),
          call_deflect_response: call_deflect_response,
          intent_after_call_deflect: Data.IntentUsage.get_intent_count_after_call_disposition(["Call deflected","Call Deflected"],params["to"] ,params["from"], location_ids),
          new_leads_after_call_deflect: Data.IntentUsage.get_leads_count_after_call_disposition(["Call deflected","Call Deflected"], params["to"], params["from"], location_ids),
          call_deflect_response_rate: calculate_response_rate_after_call(["Call deflected","Call Deflected"],dispositions, call_deflect_response),
          missed_call_texted: missed_call_texted.total_percentage,
          missed_call_response: missed_call_response,
          intent_after_missed_call: Data.IntentUsage.get_intent_count_after_call_disposition(["Missed Call Texted"], params["to"], params["from"], location_ids),
          new_leads_after_missed_call: Data.IntentUsage.get_leads_count_after_call_disposition(["Missed Call Texted"], params["to"], params["from"], location_ids),
          missed_call_response_rate: calculate_response_rate_after_call(["Missed Call Texted"],dispositions, missed_call_response),
          missed_call_rate: missed_call_texted.missed_call_rate,
          dispositions_per_day: dispositions_per_day,
          response_time: response_time.median_response_time||0,
          web_totals_by_day: web_totals_by_day,
          app_totals_by_day: app_totals_by_day,
          sms_totals_by_day: sms_totals_by_day,
          facebook_totals_by_day: facebook_totals_by_day,
          mail_totals_by_day: mail_totals_by_day,
          call_totals_by_day: call_totals_by_day,
          avg_totals_by_day: get_average_for_line_graph(web_totals_by_day, sms_totals_by_day, app_totals_by_day, facebook_totals_by_day, mail_totals_by_day, call_totals_by_day),
          line_graph_start_date: Date.to_iso8601(Date.add(DateTime.utc_now, -6)),
          web_totals: ConversationDisposition.count_channel_type_by_location_ids("WEB", location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"])),
          sms_totals: ConversationDisposition.count_channel_type_by_location_ids("SMS", location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"])),
          app_totals: ConversationDisposition.count_channel_type_by_location_ids("APP", location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"])),
          facebook_totals: ConversationDisposition.count_channel_type_by_location_ids("FACEBOOK", location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"])),
          email_totals: ConversationDisposition.count_channel_type_by_location_ids("MAIL", location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"])),
          call_totals: ConversationDisposition.count_channel_type_by_location_ids("CALL", location_ids, convert_values(params["filter"]["to"]), convert_values(params["filter"]["from"])),
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
          team_id: nil,
          role: current_user.role,
          new_leads: Enum.filter(dispositions, &(&1.name == "New Lead")) |> Enum.map(&(&1.count)) |> Enum.sum() || 0,
          new_leads_data: Enum.filter(automated, &(&1.intent in @new_leads)),
          new_user: new_user,
          active_user: active_user
        )
      end
    end
  end
  defp get_average_for_line_graph(web, sms, app, facebook,mail, call)do
    no_of_channels = 6
    Enum.map(
      0..length(web)-1,
      fn x ->
         web=elem(List.pop_at(web, x),0)
         sms=elem(List.pop_at(sms, x),0)
         app=elem(List.pop_at(app, x),0)
         facebook=elem(List.pop_at(facebook, x),0)
         mail=elem(List.pop_at(mail, x),0)
         call=elem(List.pop_at(call, x),0)

          (
             web+ sms + app + facebook + mail + call)/no_of_channels
         end
    )
  end
  defp calculate_percentage(type, dispositions) do
    total =  Enum.map(dispositions, &(&1.count)) |> Enum.sum()
    call_transferred = (dispositions |> Enum.filter(&(&1.name == "Call Transferred")) |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    call_Deflected =  (dispositions |> Enum.filter(&( &1.name == "Call Deflected"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    call_deflected =  (dispositions |> Enum.filter(&( &1.name == "Call deflected"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    call_hung_up =  (dispositions |> Enum.filter(&(&1.name == "Call Hang Up"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    missed_call_texted =  (dispositions |> Enum.filter(&(&1.name == "Missed Call Texted"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    automated = (dispositions |> Enum.filter(&(&1.name == "Automated"))  |> Enum.map( &(&1.count)) |> Enum.sum()) || 0
    case type do
      "Automated" ->
        test = dispositions |> Enum.count(&(&1.name == "GENERAL - Test")) || 0
        (automated / (if (total - (call_transferred + call_deflected + call_hung_up + test + call_Deflected + missed_call_texted))== 0.0,do: 1,else: (total - (call_transferred + call_deflected + call_hung_up + test + call_Deflected + missed_call_texted)))) * 100
      "Call deflected" ->
        call_deflected = call_deflected + call_Deflected
        (call_deflected  / (if (call_transferred + call_deflected + call_hung_up + missed_call_texted)==0.0,do: 1,else: (call_transferred + call_deflected + call_hung_up + missed_call_texted))) * 100
      "Missed Call Texted" ->
        total_percentage = ( missed_call_texted / (if (call_transferred + call_deflected + call_hung_up + missed_call_texted)==0.0,do: 1,else: (call_transferred + call_deflected + call_hung_up + missed_call_texted))) * 100
        missed_call_rate = (missed_call_texted / (if call_transferred == 0,do: 1, else: call_transferred)) * 100
        %{total_percentage: total_percentage, missed_call_rate: missed_call_rate}
    end
  end
  defp change_params(params) do
    params=Map.merge(params, params["filters"])
    params=Map.delete(params, "filters")
  end
  defp count_total_response_time(%{"location_ids" => location_ids}= params) do
    response_times = ConversationMessages.count_by_location_id(location_ids, params["from"] != "" && params["from"] || nil,params["to"] != "" && params["to"] || nil).median_response_time||0
  end
  defp convert_values(value) do
    case value do
      "" -> nil
      _-> value
    end
  end
  defp calculate_automated_percentage(dispositions, automated)do
    total =  Enum.reduce(dispositions,0,fn %{count: x},sum -> x+sum end)
    automated = Enum.filter(automated, fn auto -> auto.intent not in ["thanks", "imessage", "greetings"] end)
    automated = Enum.reduce(automated,0,fn %{count: x},sum -> x+sum end)
    (automated / if total == 0, do: 1, else: total) * 100
  end

  defp calculate_response_rate_after_call(type, dispositions, res)do

#    total = Data.ConversationCall.get_total_calls(disposition, loc_ids) |> Enum.count()
    total = Enum.filter(dispositions, &(&1.name in type)) |> Enum.map(&(&1.count)) |> Enum.sum()
    (res/(if total == 0, do: 1, else: total)) * 100
  end
  defp get_bar_graph_data(dispositions, to, from)do
    all_dispositions = Enum.map(Enum.uniq_by(dispositions, fn x -> x.name end), fn x -> x.name end)
    dispositions = Enum.frequencies(dispositions)
    days = case %{to: to, from: from} do
      %{to: nil, from: nil} ->
        Enum.map(-6..-0, &Date.add(DateTime.utc_now(), &1))
      %{to: nil, from: from} ->
        range = Date.range(from, DateTime.utc_now())
        Enum.map(range, fn (x) -> x end)|> IO.inspect(label: "my label")
      %{to: to, from: nil} ->
        oldest=Enum.min_by(dispositions, fn {x,_} -> x.date end, Date)
        range = Date.range(oldest, to)
        Enum.map(range, fn (x) -> x end)
      %{to: to, from: from} ->
        range = Date.range(from, to)
        Enum.map(range, fn (x) -> x end)
    end
    result=Enum.reduce(
      all_dispositions,
      [],
      fn x, acc ->
        result=Enum.reduce(
          days,
          [],
          fn y, acc1 ->
            if (
                 t = Enum.find(
                   dispositions,
                   fn {map, count} -> map.date == y && map.name == x end
                 ))
              do
              acc1 ++ [elem(t,1)]
            else
              acc1 ++ [0]
            end
          end
        )
        acc++[result]
      end
    )
    result=Enum.reduce(
      0..length(all_dispositions),
      %{},
      fn x, acc -> Map.merge(acc, %{Enum.at(all_dispositions, x) => Enum.at(result, x)}) end
    )
    result=Poison.encode!(result)
    %{bar_graph_data: result, start_date: List.first(days)}


  end

end