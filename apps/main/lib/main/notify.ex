defmodule MainWeb.Notify do
  @moduledoc """
  This module is used to notify a location admin.
  """

  require Logger

  alias Data.{Location, Conversations, TeamMember, TimezoneOffset, MemberChannel, User}
  alias Data.Schema.MemberChannel, as: Channel

  @url "[url]/admin/conversations/[conversation_id]/"
  @super_admin Application.get_env(:main, :super_admin)
  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @endpoint Application.get_env(:main, :endpoint)

  def send_to_teammate(conversation_id, message, location, team_member,user) do
    IO.inspect("#########")
    IO.inspect(1)
    IO.inspect("#########")
    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()
    body =case is_binary(user) do
      true ->      Enum.join([user, "sent you a message" ,message, link[:url]], " ")
      _ ->      Enum.join([user.first_name,user.last_name, "sent you a message" ,message, link[:url]], " ")
    end

    timezone_offset = TimezoneOffset.calculate(location.timezone)
    current_time_string =
      Time.utc_now()
      |> Time.add(timezone_offset)
      |> to_string()

    available=
      location
      |> TeamMember.get_available_by_location(current_time_string)
      |> Enum.map(&TeamMember.fetch_admins/1)
      |> Enum.filter(&(&1))
      |> Enum.filter(&(&1.phone_number == team_member.user.phone_number))
      |> List.first


    if team_member.user.use_email do
      conversation = Conversations.get(conversation_id) |> fetch_member()
      member = conversation.member
      subject = if member do
        member = [
                   member.first_name,
                   member.last_name,
                   conversation.original_number
                 ] |> Enum.join(" ")

        "New message from #{member}"
      else
        "New message from #{conversation.original_number}"
      end

      team_member.user.email
      |> Main.Email.generate_email(body, subject)
      |> Main.Mailer.deliver_now()
      |> IO.inspect()
    end

    if available && available.use_sms do
      message = %{
        provider: :twilio,
        from: location.phone_number,
        to: validate_phone_number(available.country <> available.phone_number),
        body: body
      }


      @chatbot.send(message)
    end

    :ok
  end


  def send_to_teammate(conversation_id, message, location, team_member) do
    IO.inspect("#########")
    IO.inspect(2)
    IO.inspect("#########")
    location = Location.get_by_phone(location)

    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()

    body = Enum.join(["You've been assigned to this conversation:", message, link[:url]], " ")

    timezone_offset = TimezoneOffset.calculate(location.timezone)
    current_time_string = Time.utc_now() |> Time.add(timezone_offset) |> to_string()

    available=
      location
      |> TeamMember.get_available_by_location(current_time_string)
      |> Enum.map(&TeamMember.fetch_admins/1)
      |> Enum.filter(&(&1))
      |> Enum.filter(&(&1.phone_number == team_member.user.phone_number))
      |> List.first


    if team_member.user.use_email do
      conversation=  Conversations.get(conversation_id) |> fetch_member()
      member = conversation.member
      subject = if member do
        member = [
                   member.first_name,
                   member.last_name,
                   conversation.original_number
                 ] |> Enum.join(" ")

        "New message from #{member}"
      else
        "New message from #{conversation.original_number}"
      end

      team_member.user.email
      |> Main.Email.generate_email(body, subject)
      |> Main.Mailer.deliver_now()
    end

    if available && available.use_sms do
      message = %{
        provider: :twilio,
        from: location.phone_number,
        to: validate_phone_number(available.country <> available.phone_number),
        body: body
      }

      @chatbot.send(message)
    end

    :ok
  end

  @doc """
  Send a notification to the super admin defined in the config. It will create a short URL.
  """
  def send_to_admin(conversation_id, message, location, member_role \\ @super_admin) do
    location = Location.get_by_phone(location)
    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()
    
    template =
      case member_role do
        "location-admin" -> "You've a new message"
        _ -> "You've been assigned to this conversation:"
        end

    body =
      [
        template,
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
      |> Enum.map(&TeamMember.fetch_admins/1)
      |> Enum.uniq_by(fn x -> x.id end)
      |> IO.inspect(label: "Available Admins")

    all_admins =
      %{role: "location-admin"}
      |> TeamMember.get_by_location_id(location.id)
      |> Enum.filter(&(&1.user.role == "location-admin"))
      |> Enum.filter(&(&1))
      |> Enum.uniq_by(fn x -> x.id end)
      |> IO.inspect(label: "All Admins")

    role =
      case member_role do
        "location-admin" -> "location-admin"
        _ -> "admin"
      end

    conversation = Conversations.get(%{role: role},conversation_id,false) |> fetch_member()

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
        |> IO.inspect()
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
          to: validate_phone_number(admin.country<>admin.phone_number),
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

  def fetch_member(%{original_number: << "CH", _rest :: binary >> = channel} = conversation) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel) do
      Map.put(conversation, :member, channel.member)
    end
  end
  def fetch_member(conversation), do: conversation

  def validate_phone_number(phone_number) do
    if String.starts_with?(phone_number, "+"), do: phone_number, else: "+" <> phone_number
end
end
