defmodule MainWeb.Helper.Formatters  do
  alias Calendar.Strftime
  require Logger

  alias Data.{MemberChannel,User}
  alias Data.Schema.MemberChannel, as: Channel

  def format_role("admin") do
    "Super Admin"
  end

  def format_role(role) do
    role
    |> String.split("-")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def format_user(number)do
    case User.get_by_phone number do
      nil -> format_phone(number)
      user -> Enum.join([user.first_name, user.last_name, ""], " ")
      _ -> format_phone(number)
    end
  end

  def format_phone(<<"+", phone>>) do
    phone
  end
  def format_phone(<<"APP:+", phone>>) do
    "#{phone}"
  end

  def format_phone(<<"messenger:", _rest :: binary>>), do: "Facebook Visitor"

  def format_phone(<<"CH", _rest :: binary>> = channel_id) do
    with [%Channel{} = channel] <- MemberChannel.get_by_channel_id(channel_id) do
      Enum.join([channel.member.first_name, channel.member.last_name], " ")
    else
      [] ->
        "Unknown Vistor"
    end
  end

  def format_phone(phone_number) do
    regex = ~r{([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)}

    if Regex.match?(regex,phone_number) do
      "Email Bot"
    else
      phone_number
    end
  end

  def format_assigned(<<"+1", _rest :: binary>>), do: "SMS Bot"
  def format_assigned(<<"messenger:", _rest :: binary>>), do: "Facebook Bot"
  def format_assigned(<<"CH", _rest :: binary>>), do: "Website Bot"
  def format_assigned(<<"APP", _rest :: binary>>), do: "App Bot"
  def format_assigned(phone_number) do
    regex = ~r{([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)}

    if Regex.match?(regex,phone_number) do
      "Email Bot"
    else
      "SMS Bot"
    end
  end

  def format_team_member(team_member) do
    name = Enum.join([team_member.first_name, team_member.last_name], " ")

    if name == "" do
      "#{format_phone(team_member.phone_number)}"
    else
      name
    end
  end

  def format_date_time_split(datetime, timezone \\ "PST8PDT") do
    datetime = Calendar.DateTime.shift_zone!(datetime, timezone)
    Strftime.strftime!(datetime, "%m/%d/%Y | %I:%M %p")
  end

  def format_date(datetime, timezone \\ "PST8PDT") do
    datetime = Calendar.DateTime.shift_zone!(datetime, timezone)
    now = Calendar.DateTime.shift_zone!(DateTime.utc_now(), timezone)

    date = DateTime.to_date(datetime)
    now_date = DateTime.to_date(now)

    case Date.diff(date, now_date) do
      0 -> # Today
        now
        |> Calendar.DateTime.diff(datetime)
        |> parse_date(datetime)
      -1 -> # Yesterday
        datetime
        |> Calendar.DateTime.to_time()
        |> Calendar.Time.Format.iso8601()
        |> to_time(:yesterday)
      _ ->
        Strftime.strftime!(datetime, "%m/%d/%Y %I:%M %p")
    end
  end

  defp parse_date({:ok, seconds, _, _}, _date) when seconds < 60, do: "now"
  defp parse_date({:ok, seconds, _, _}, _date) when seconds < 120, do: "1 minute ago"
  defp parse_date({:ok, seconds, _, _}, _date) when seconds < 3600, do: "#{div(seconds, 60)} minutes ago"
  defp parse_date({:ok, seconds, _, _}, _date) when seconds < 7200, do: "1 hour ago"
  defp parse_date({:ok, seconds, _, _}, _date) when seconds < 18000, do: "#{div(seconds, 3600)} hours ago"
  defp parse_date({:ok, _seconds, _, _}, datetime) do
    datetime
    |> Calendar.DateTime.to_time()
    |> Calendar.Time.Format.iso8601()
    |> to_time(:today)
  end

  defp to_time(<<hour :: binary - size(2), ":", minute :: binary - size(2), _rest :: binary>>, :today) do
    "Today at #{adjust_hour(hour, minute)}"
  end

  defp to_time(<<hour :: binary - size(2), ":", minute :: binary - size(2), _rest :: binary>>, :yesterday) do
    "Yesterday at #{adjust_hour(hour, minute)}"
  end

  defp adjust_hour(hour, minute) do
    hour = String.to_integer(hour)

    cond do
      hour - 12 == 0 or hour === 0 ->
        "12:#{minute} AM"
      hour > 12 ->
        "#{hour - 12}:#{minute} PM"
      hour == 12 ->
        "12:#{minute} PM"
      true ->
        "#{hour}:#{minute} AM"
    end
  end

  def format_time_sec(s) when s == nil do
    "0m 0s"
  end
  def format_time_sec(seconds)do
    sec = rem(seconds, 60)
          |> sec_string
    minutes = div(seconds, 60)
    hours = div(minutes, 60)
            |> hour_string
    minutes = rem(minutes, 60)
              |> min_string
    hours <> minutes <> sec

  end

  defp sec_string(s) when s ==0, do: "0s"
  defp sec_string(s) when s < 10, do: "#{s}s"
  defp sec_string(s), do: "#{s}s"
  defp min_string(s) when s == 0, do: "0m "
  defp min_string(s) when s < 10, do: "#{s}m "
  defp min_string(s), do: "#{s}m "
  defp hour_string(s) when s == 0, do: ""
  defp hour_string(s) when s < 10, do: "#{s}h "
  defp hour_string(s), do: "#{s}h "

  def format_comma_numbers(nil)do
     ""
  end
  def format_comma_numbers(value)do
     delimit_integer(value,",")
     |> String.Chars.to_string
  end
  defp delimit_integer(number, delimiter) do
    abs(number)
    |> Integer.to_charlist()
    |> :lists.reverse()
    |> delimit_integer(delimiter, [])
  end

  defp delimit_integer([a, b, c, d | tail], delimiter, acc) do
    delimit_integer([d | tail], delimiter, [delimiter, c, b, a | acc])
  end

  defp delimit_integer(list, _, acc) do
    :lists.reverse(list) ++ acc
  end

end
