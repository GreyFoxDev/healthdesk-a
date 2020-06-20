defmodule MainWeb.Notify do
  @moduledoc """
  This module is used to notify a location admin.
  """

  require Logger

  alias Data.{Location, Conversations, TeamMember, TimezoneOffset}

  @url "[url]/admin/teams/[team_id]/locations/[location_id]/conversations/[conversation_id]/conversation-messages"
  @super_admin Application.get_env(:main, :super_admin)
  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @endpoint Application.get_env(:main, :endpoint)

  def send_to_teammate(conversation_id, message, location, team_member) do
    location = Location.get_by_phone(location)

    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[team_id]", location.team_id)
      |> String.replace("[location_id]", location.id)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()

    body = Enum.join(["You've been assigned to this conversation:", message, link[:url]], " ")

    timezone_offset = TimezoneOffset.calculate(location.timezone)
    current_time_string =
      Time.utc_now()
      |> Time.add(timezone_offset)
      |> to_string()

    [available] =
      location
      |> TeamMember.get_available_by_location(current_time_string)
      |> Enum.filter(&(&1.phone_number == team_member.user.phone_number))

    if team_member.user.use_email do
      conversation = Conversations.get(conversation_id)
      member = conversation.member
      subject = if member do
        member = [
          member.first_name,
          member.last_name,
          conversation.original_number
        ] |> Enum.join(" ")

        "New message from #{member}"
      else
        "New message from #{conversation.original_phone}"
      end

      team_member.user.email
      |> Main.Email.generate_email(body, subject)
      |> Main.Mailer.deliver_now()
    end

    if available && available.use_sms do
      message = %{
        provider: :twilio,
        from: location.phone_number,
        to: available.phone_number,
        body: body
      }

      @chatbot.send(message)
    end

    :ok
  end

  @doc """
  Send a notification to the super admin defined in the config. It will create a short URL.
  """
  def send_to_admin(conversation_id, message, location, member \\ @super_admin) do
    location = Location.get_by_phone(location)

    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[team_id]", location.team_id)
      |> String.replace("[location_id]", location.id)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()

    body =
      [
        "You've been assigned to this conversation:",
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
      |> Enum.filter(&(&1.user.role == "location-admin"))

    _ = Enum.each(all_admins, fn(admin) ->
      if admin.user.use_email do
        conversation = Conversations.get(conversation_id)
        member = conversation.member
        subject = if member do
          member = [
            member.first_name,
            member.last_name,
            conversation.original_number
          ] |> Enum.join(" ")

          "New message from #{member}"
        else
          "New message from #{conversation.original_phone}"
        end

        admin.user.email
        |> Main.Email.generate_email(body, subject)
        |> Main.Mailer.deliver_now()
      end
    end)

    _ = Enum.each(available_admins, fn(admin) ->
      if admin.use_sms do
        message = %{
          provider: :twilio,
          from: location.phone_number,
          to: admin.phone_number,
          body: body
        }

        @chatbot.send(message)
      end
    end)

    if location.slack_integration && location.slack_integration != "" do
      headers = [{"content-type", "application/json"}]

      body = Jason.encode! %{text: String.replace(body, "\n", " ")}

      Tesla.post location.slack_integration, body, headers: headers
    end

    alert_info = %{location: location, convo: conversation_id}
    MainWeb.Endpoint.broadcast("alert:admin", "broadcast", alert_info)
    MainWeb.Endpoint.broadcast("alert:#{location.id}", "broadcast", alert_info)

    :ok
  end

end
