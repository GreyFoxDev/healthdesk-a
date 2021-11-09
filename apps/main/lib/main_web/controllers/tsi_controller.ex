defmodule MainWeb.TsiController do
  use MainWeb, :controller

  import Plug.Conn, only: [send_resp: 3, assign: 3]


  plug MainWeb.Plug.AllowFrom
  plug MainWeb.Plug.ValidateApiKey

  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.Schema.Conversation, as: Schema
  alias Main.Service.Appointment
  alias Data.Team

  alias MainWeb.{Notify}

  alias Data.{Member, TimezoneOffset, TeamMember, Conversations}

  @role %{role: "admin"}
  @url "[url]/location_admin/conversations/[conversation_id]/"
  #@super_admin Application.get_env(:main, :super_admin)
  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @endpoint Application.get_env(:main, :endpoint)

  @new_leads [
    "salesQuestion",
    "getTour",
    "getTrialPass",
    "getGuestPass",
    "getMonthPass",
    "getDayPass",
    "getWeekPass",
  ]

  def new(conn, %{"phone-number" => phone_number, "api_key" => api_key, "ticket" => "new"} = params) do
    location = conn.assigns.location
    phone = "APP:#{format_phone(phone_number)}"

    first_name = params["member-first"]
    last_name = params["member-last"]

    {:ok, _member} =
      with %Data.Schema.Member{} = member <- Member.get_by_phone_number(@role, phone) do
        update_member_data(member.id, first_name, last_name)
      else
        nil ->
          create_member_data(location.team_id, first_name, last_name, phone)
      end

    conn
    |> assign(:title, location.team.team_name)
    |> render_new(phone_number, api_key)
  end
  def new(conn, %{"phone-number" => phone_number, "api_key" => api_key, "ticket" => "open"} = params) do

    location = conn.assigns.location

    phone = "APP:#{format_phone(phone_number)}"

    first_name = params["member-first"]
    last_name = params["member-last"]

    {:ok, _member} =
      with %Data.Schema.Member{} = member <- Member.get_by_phone_number(@role, phone) do
        update_member_data(member.id, first_name, last_name)
      else
        nil ->
          create_member_data(location.team_id, first_name, last_name, phone)
      end
    with {:ok, %Schema{} = convo} <- C.find_conversation({phone, location.phone_number}) do
      conn
      |> assign(:title, location.team.team_name)
      |> redirect(to: tsi_path(conn, :edit, api_key, convo.id))
    else
      _err ->

        conn
        |> assign(:title, location.team.team_name)
        |> render_new(phone_number, api_key)
    end
  end

  def new(conn, %{"phone-number" => phone_number, "api_key" => api_key} = params) do
    location = conn.assigns.location
    phone = "APP:#{format_phone(phone_number)}"

    first_name = params["member-first"]
    last_name = params["member-last"]

    {:ok, _member} =
      with %Data.Schema.Member{} = member <- Member.get_by_phone_number(@role, phone) do
        update_member_data(member.id, first_name, last_name)
      else
        nil ->
          create_member_data(location.team_id, first_name, last_name, phone)
      end
    with {:ok, %Schema{status: "open"} = convo} <- C.find_conversation({phone, location.phone_number}) do
      conn
      |> assign(:title, location.team.team_name)
      |> redirect(to: tsi_path(conn, :edit, api_key, convo.id))
    else
      {:ok, %Schema{status: "pending"} = convo} ->
        conn
        |> assign(:title, location.team.team_name)
        |> redirect(to: tsi_path(conn, :edit, api_key, convo.id))
      _err ->
        conn
        |> assign(:title, location.team.team_name)
        |> render_new(phone_number, api_key)
    end
  end

  def new(conn, %{"unique-id" => unique_id, "api_key" => api_key} = _params),
      do: render_new(conn, unique_id, api_key)

  def new(conn, _params),
      do: send_resp(conn, 400, "Bad request")

  def edit(conn, %{"api_key" => api_key,"id" => convo_id}=params) do
    location = conn.assigns.location

    with %Schema{} = convo <- C.get(convo_id) do
      <<"APP:", phone_number :: binary>> = convo.original_number
      layout = get_edit_layout_for_team(conn)


      case convo.status do
        "open" ->
            Notify.send_to_teammate(convo_id, params["message"], location, convo.team_member, convo.member )
        _ ->
          Notify.send_to_admin(convo_id, params["message"], location.phone_number, "location-admin")
      end

      conn
      |> put_layout({MainWeb.LayoutView, layout})
      |> assign(:title, location.team.team_name)
      |> render(
           "edit.html",
           api_key: api_key,
           convo_id: convo_id,
           phone_number: phone_number,
           changeset: CM.get_changeset()
         )
    end
  end

  def edit(conn, params), do:
    send_resp(conn, 400, "Bad request")

  def create(conn, %{"phone_number" => phone_number, "api_key" => api_key} = params) do
    phone_number = "APP:#{format_phone(phone_number)}"
    location = conn.assigns.location

    with {:ok, %Schema{} = convo} <- C.find_or_start_conversation({phone_number, location.phone_number}) do
      message = extract_question(params)
      _ = CM.create(
        %{
          "conversation_id" => convo.id,
          "phone_number" => phone_number,
          "message" => message,
          "sent_at" => DateTime.utc_now()
        }
      )

      _ = CM.create(
        %{
          "conversation_id" => convo.id,
          "phone_number" => location.phone_number,
          "message" => build_answer(params),
          "sent_at" => DateTime.add(DateTime.utc_now(), 2)
        }
      )

      close_conversation(convo.id, location)
      conn
      |> assign(:title, location.team.team_name)
      |> redirect(to: tsi_path(conn, :edit, api_key, convo.id))
    end
  end

  def create(conn, _params) do
    Plug.Conn.send_resp(conn, 400, "Bad request")
  end

  def update(conn, %{"id" => convo_id, "api_key" => api_key} = params) do
    location = conn.assigns.location

    with %Schema{} = convo <- C.get(convo_id) do
      message= params["message"]||params["foo"]["message"]
      <<"APP:", _phone_number :: binary>> = convo.original_number
      _res=CM.create(
        %{
          "conversation_id" => convo.id,
          "phone_number" => convo.original_number,
          "message" => message,
          "sent_at" => DateTime.utc_now()
        }
      )

      _member = Member.get_by_phone_number(@role, convo.original_number)

      if convo.status == "closed" do

        message
        |> ask_wit_ai(convo_id, location)
        |> case do
             {:ok, response , intent} ->
               {:ok, saved_message} = CM.create(
                 %{
                   "conversation_id" => convo.id,
                   "phone_number" => location.phone_number,
                   "message" => response,
                   "sent_at" => DateTime.add(DateTime.utc_now(), 2)
                 }
               )
               _ = Data.Query.IntentUsage.create(
               %{
                    "message_id" => saved_message.id,
                    "intent" => intent
               }
               )

               close_conversation(convo_id, location, intent)
             {:unknown, response} ->

               _ = CM.create(
                 %{
                   "conversation_id" => convo.id,
                   "phone_number" => location.phone_number,
                   "message" => response,
                   "sent_at" => DateTime.add(DateTime.utc_now(), 2)
                 }
               )

               C.pending(convo_id)
               Main.LiveUpdates.notify_live_view({location.id, :updated_open})
#               :ok =
#                 Notify.send_to_admin(
#                   convo.id,
#                   "Message From: #{convo.original_number}\n#{message}",
#                   location.phone_number
#                 )
           end
      end
      params = %{"api_key" => api_key, "id" => convo.id, "message" => message}
      conn
      |> assign(:title, location.team.team_name)
      |> redirect(to: tsi_path(conn, :edit, api_key, convo.id, params))

    end
  end

  defp extract_question(%{"facilities" => question}), do: question
  defp extract_question(%{"personnel" => question}), do: question
  defp extract_question(%{"member_services" => question}), do: question
  defp extract_question(_), do: "No message sent"

  defp build_answer(%{"member_services" => _}) do
    """
    Please contact Member Services at 877.258.2311 between the hours of 9:30 am
    – 5:30 pm ET M-F.
    """
  end
  defp build_answer(_) do
    "We've received your request. You may leave a comment below if you'd like."
  end
  defp format_phone(<<"+", phone>>) do
    phone
  end
  defp format_phone(<<phone>>) do
    phone
  end
  defp format_phone(unique_id) do
    String.replace(unique_id, " ", "")
  end
  defp render_new(conn, unique_id, api_key) do
    if String.length(unique_id) >= 10 do
      location = conn.assigns.location
      {template_name,title} =
        case location.location_name do
          <<"ATC - ", _rest :: binary>> -> {"around_the_clock_fitness_new.html", "around the clock fitness new"}
          <<"PB - ", _rest :: binary>> -> {"palm_beach_sports_club_new.html","palm beach sports club new"}
          <<"TW - ", _rest :: binary>> -> {"total_woman_new.html","total woman new"}
          _ -> {"new.html","In-App Messaging"}
        end

      conn
      |> assign(:title, title)
      |> put_layout({MainWeb.LayoutView, :tsi})
      |> render(template_name, api_key: api_key, phone_number: unique_id)
    else
      send_resp(conn, 400, "Bad request")
    end
  end
  defp ask_wit_ai(question, convo_id, location) do

    bot_id = Team.get_bot_id_by_location_id(location.id)
    with {:ok, _pid} <- WitClient.MessageSupervisor.ask_question(self(), question, bot_id) do
      receive do
        {:response, response} ->
          intent = elem(response, 0)
#          intent = intent["intent"]
#          intent = hd(intent)
#          intent = intent["value"]
          message =  Appointment.get_next_reply(convo_id, response, location.phone_number)
          if String.contains?(message,location.default_message) do
            {:unknown, message}
          else
            {:ok, message, intent}
          end
        _ ->
          {:unknown, location.default_message}
      end
    else

      {:error, _error} ->
        {:unknown, location.default_message}
    end
  end
  defp close_conversation(convo_id, location, intent \\ "") do
    disposition =
    if intent in @new_leads do
      %{role: "system"}
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Enum.find(&(&1.disposition_name == "New Leads"))
      else
        %{role: "system"}
        |> Data.Disposition.get_by_team_id(location.team_id)
        |> Enum.find(&(&1.disposition_name == "Automated"))
    end


    if disposition do
      Data.ConversationDisposition.create(%{"conversation_id" => convo_id, "disposition_id" => disposition.id})

      _ =  %{
        "conversation_id" => convo_id,
        "phone_number" => location.phone_number,
        "message" =>
          "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.add(DateTime.utc_now(), 3)
      }
      |> CM.create()
    else
      _ = %{
        "conversation_id" => convo_id,
        "phone_number" => location.phone_number,
        "message" =>
          "CLOSED: Closed by System",
        "sent_at" => DateTime.add(DateTime.utc_now(), 3)
      }
      |> CM.create()
    end

    C.close(convo_id)
  end
  def send_to_location_admin(conversation_id, message, location) do
    #location = Location.get_by_phone(location)
    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()

    body =
      [
        "You've a new message",
        message,
        link[:url]
      ] |> Enum.join(" ")


    timezone_offset = TimezoneOffset.calculate(location.timezone)
    current_time_string =
      Time.utc_now()
      |> Time.add(timezone_offset)
      |> to_string()
    available_admins =
      location
      |> TeamMember.get_available_by_location(current_time_string)
      |> Enum.filter(&(&1.role == "location-admin"))

    all_admins =
      %{role: "system"}
      |> TeamMember.get_by_location_id(location.id)
      |> Enum.filter(&(&1.user.role == "location-admin" && is_nil(&1.user.logged_in_at)))

    conversation = Conversations.get(%{role: "location-admin"},conversation_id,false) |> fetch_member()

    _ = Enum.each(all_admins, fn(admin) ->
      if admin.user.use_email do
        member = conversation.member
        subject = if member do
          member = [
                     member.first_name,
                     member.last_name,
                     member.email || "",
                     location.location_name,
                     member.phone_number
                   ] |> Enum.join(", ")

          "New message from #{member}"
        else
          "New message from #{conversation.original_number}"
        end
        admin.user.email
        |> Main.Email.generate_email(body, subject)
        |> Main.Mailer.deliver_now()

      end

    end)

    _ = Enum.each(available_admins, fn(admin) ->
      if admin.use_sms do
        member = conversation.member
        body = if member do
          member = [
                     member.first_name,
                     member.last_name,
                     member.email || "",
                     location.location_name,
                     member.phone_number
                   ] |> Enum.join(", ")
          body <> " from #{member}"
        else
          body
        end
        message = %{
          provider: :twilio,
          from: location.phone_number,
          to: validate_phone_number(admin.phone_number),
          body: body
        }

        @chatbot.send(message)
      end
    end)

    if location.slack_integration && location.slack_integration != "" do
      headers = [{"content-type", "application/json"}]
      member = conversation.member
      body = if member do
        member = [
                   member.first_name,
                   member.last_name,
                   member.email || "",
                   location.location_name,
                   member.phone_number
                 ] |> Enum.join(", ")
        body <> " from #{member}"
      else
        body
      end
      body = Jason.encode! %{text: String.replace(body, "\n", " ")}

      Tesla.post location.slack_integration, body, headers: headers
    end

    alert_info = %{location: location, convo: conversation_id}
    MainWeb.Endpoint.broadcast("alert:admin", "broadcast", alert_info)
    MainWeb.Endpoint.broadcast("alert:#{location.id}", "broadcast", alert_info)

    :ok
  end
  defp create_member_data(team_id, first_name, nil, phone) do
    Member.create(
      %{
        team_id: team_id,
        first_name: first_name,
        phone_number: phone
      }
    )
  end

  defp create_member_data(team_id, first_name, last_name, phone) do
    Member.create(
      %{
        team_id: team_id,
        first_name: first_name,
        last_name: last_name,
        phone_number: phone
      }
    )
  end

  defp update_member_data(member_id, nil, nil), do: {:ok, member_id}

  defp update_member_data(member_id, first_name, nil) do
    Member.update(member_id, %{first_name: first_name})
  end

  defp update_member_data(member_id, first_name, last_name) do
    Member.update(member_id, %{first_name: first_name, last_name: last_name})
  end

  defp get_edit_layout_for_team(conn) do
    case conn.assigns.location.location_name do
      <<"ATC - ", _rest :: binary>> -> :around_the_clock_fitness_conversation
      <<"PB - ", _rest :: binary>> -> :palm_beach_sports_club_conversation
      <<"TW - ", _rest :: binary>> -> :total_woman_conversation
      _ -> :tsi_conversation
    end
  end


  def fetch_member(conversation), do: conversation

  def validate_phone_number(phone_number) do
    if String.starts_with?(phone_number, "+"), do: phone_number, else: "+" <> phone_number
  end

end
