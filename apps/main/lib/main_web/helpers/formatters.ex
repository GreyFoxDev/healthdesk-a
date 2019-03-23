defmodule MainWeb.Helper.Formatters  do
  alias Calendar.Strftime
  require Logger

  def format_phone(<< "+1", area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    Enum.join([area_code, prefix, line], "-")
  end

  def format_phone(<< area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    Enum.join([area_code, prefix, line], "-")
  end

  def format_phone(phone_number) do
    phone_number
  end

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

    now
    |> Calendar.DateTime.diff(datetime)
    |> parse_date(datetime)
  end

  def parse_date({:ok, seconds, _, _}, _date) when seconds < 60, do: "now"
  def parse_date({:ok, seconds, _, _}, _date) when seconds < 120, do: "1 minute ago"
  def parse_date({:ok, seconds, _, _}, _date) when seconds < 3600, do: "#{div(seconds, 60)} minutes ago"
  def parse_date({:ok, seconds, _, _}, _date) when seconds < 7200, do: "1 hour ago"
  def parse_date({:ok, seconds, _, _}, _date) when seconds < 18000, do: "#{div(seconds, 3600)} hours ago"
  def parse_date({:ok, seconds, _, _}, datetime) when seconds < 86400 do
    datetime
    |> Calendar.DateTime.to_time()
    |> Calendar.Time.Format.iso8601()
    |> to_time(:today)
  end
  def parse_date({:ok, seconds, _, _}, datetime) when seconds < 172800 do
    datetime
    |> Calendar.DateTime.to_time()
    |> Calendar.Time.Format.iso8601()
    |> to_time(:yesterday)
  end
  def parse_date(_seconds, datetime) do
    Strftime.strftime!(datetime, "%m/%d/%Y")
  end

  def to_time(<< hour::binary-size(2), ":", minute::binary-size(2), _rest::binary >>, :today) do
    "Today at #{adjust_hour(hour, minute)}"
  end

  def to_time(<< hour::binary-size(2), ":", minute::binary-size(2), _rest::binary >>, :yesterday) do
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
