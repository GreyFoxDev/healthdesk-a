defmodule MainWeb.Helper.Formatters  do

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

  def format_date(datetime) do
    DateTime.utc_now()
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
  def parse_date(_seconds, date) do
    Calendar.DateTime.Format.httpdate(date)
  end

  def to_time(<< hour::binary-size(2), ":", minute::binary-size(2), _rest::binary >>, :today) do
    "Today at #{hour}:#{minute}"
  end

  def to_time(<< hour::binary-size(2), ":", minute::binary-size(2), _rest::binary >>, :yesterday) do
    "Yesterday at #{hour}:#{minute}"
  end
end
