defmodule MainWeb.Helper.Formatters  do
  alias Calendar.Strftime
  require Logger

  alias Data.MemberChannel
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

  def format_phone(<< "+1", area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    "+1 #{Enum.join([area_code, prefix, line], "-")}"
  end

  def format_phone(<< area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    "+1 #{Enum.join([area_code, prefix, line], "-")}"
  end

  def format_phone(<< "messenger:", _rest :: binary >>), do: "Facebook Visitor"

  def format_phone(<< "CH", _rest :: binary >> = channel_id) do
    with %Channel{} = channel <- MemberChannel.get_by_channel_id(%{role: "admin"}, channel_id) do
      Enum.join([channel.member.first_name, channel.member.last_name], " ")
    else
      nil ->
        "Unknown Vistor"
    end
  end

  def format_phone(phone_number) do
    "Unknown Visitor"
  end

  def format_assigned(<< "+1", _rest :: binary >>), do: "SMS Bot"
  def format_assigned(<< "messenger:", _rest :: binary >>), do: "Facebook Bot"
  def format_assigned(<< "CH", _rest :: binary >>), do: "Website Bot"
  def format_assigned(_), do: "Unknown"

  def format_team_member(team_member) do
    name = Enum.join([team_member.first_name, team_member.last_name], " ")

    if name == "" do
      "+1 #{format_phone(team_member.phone_number)}"
    else
      name
    end
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
        Strftime.strftime!(datetime, "%m/%d/%Y")
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

  defp to_time(<< hour::binary-size(2), ":", minute::binary-size(2), _rest::binary >>, :today) do
    "Today at #{adjust_hour(hour, minute)}"
  end

  defp to_time(<< hour::binary-size(2), ":", minute::binary-size(2), _rest::binary >>, :yesterday) do
    "Yesterday at #{adjust_hour(hour, minute)}"
  end

  defp adjust_hour(hour, minute) do
    hour = String.to_integer(hour)

    cond do
      hour - 12 == 0 ->
        "12:#{minute} AM"
      hour > 12 ->
        "#{hour - 12}:#{minute} PM"
      true ->
        "#{hour}:#{minute} AM"
    end
  end

end
