defmodule MainWeb.Notify do
  @moduledoc """
  This module is used to notify a location admin.
  """

  require Logger

  alias Data.{Location, TeamMember, TimezoneOffset}

  @url "[url]/admin/teams/[team_id]/locations/[location_id]/conversations/[conversation_id]/conversation-messages"
  @super_admin Application.get_env(:main, :super_admin)
  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @endpoint Application.get_env(:main, :endpoint)

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

    body = Enum.join([message, link[:url]], "\n")


    timezone_offset = TimezoneOffset.calculate(location.timezone)
    current_time_string = Time.add(Time.utc_now(), timezone_offset)
    location_admins =
      location
      |> TeamMember.get_available_by_location()
      |> Enum.filter(&(&1.role == "location-admin"))

    _ = Enum.each(location_admins, fn(admin) ->
      if admin.use_sms do
        message = %{
          provider: :twilio,
          from: location.phone_number,
          to: admin.phone_number,
          body: body
        }

        @chatbot.send(message)
      end

      if admin.use_email do
      end
    end)

    message = %{
      provider: :twilio,
      from: location.phone_number,
      to: member,
      body: body
    }

    # @chatbot.send(message)

    if location.slack_integration && location.slack_integration != "" do
      headers = [{"content-type", "application/json"}]

      body = Jason.encode! %{text: body}

      Tesla.post location.slack_integration, body, headers: headers
    end

    alert_info = %{location: location, convo: conversation_id}
    MainWeb.Endpoint.broadcast("alert:admin", "broadcast", alert_info)
    MainWeb.Endpoint.broadcast("alert:#{location.id}", "broadcast", alert_info)


    :ok
  end

end
