defmodule MainWeb.Intents.ClassSchedule do
  @moduledoc """
  This handles class schedule responses
  """

  alias Main.Integrations.Mindbody

  alias Data.{
    ClassSchedule,
    HolidayHours,
    Location
  }

  @behaviour MainWeb.Intents

  @classes "[date]:\n[classes]"
  @no_classes "There are no classes scheduled for [date_prefix]. Please ask about a different day."
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  @impl MainWeb.Intents
  def build_response(args, location) when is_binary(location),
    do: build_response(args, Location.get_by_phone(location))

  def build_response([datetime: {datetime, _}] = _args, location),
    do: build_response([datetime: datetime], location)

  def build_response([datetime: datetime], %{mindbody_location_id: mb_id} = location) when mb_id not in [nil, ""] do
    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime

    date = "#{year}-#{month}-#{day}"

    classes =
      location
      |> Mindbody.get_classes(date, date)
      |> Stream.map(&format_schedule/1)
      |> Enum.join("\n")

    if classes != "" do
      @classes
      |> String.replace("[date]", "#{month}-#{day}-#{year}")
      |> String.replace("[classes]", classes)

    else
      {term, day_of_week} = get_day_of_week({year, month, day}, location.id)

      String.replace(@no_classes, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))
    end
  end

  def build_response([datetime: datetime], location) do
    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime

    date =
    {year, month, day}
    |> convert_to_integer()
    |> Calendar.Date.from_erl!()

    classes =
      location.id
      |> ClassSchedule.all()
      |> Stream.filter(fn class -> class.date == date end)
      |> Stream.map(&format_schedule/1)
      |> Enum.join("\n")

    if classes != "" do
      @classes
      |> String.replace("[date]", "#{month}-#{day}-#{year}")
      |> String.replace("[classes]", classes)

    else
      {term, day_of_week} = get_day_of_week({year, month, day}, location.id)

      String.replace(@no_classes, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))
    end
  end

  def build_response([], %{mindbody_location_id: mb_id} = location) when mb_id not in [nil, ""] do
    date =
      location.timezone
      |> Calendar.Date.today!()
      |> to_string()

    classes =
      location
      |> Mindbody.get_classes(date, date)
      |> Stream.map(&format_schedule/1)
      |> Enum.join("\n")

    if classes != "" do
      @classes
      |> String.replace("[date]", "#{date.month}-#{date.day}-#{date.year}")
      |> String.replace("[classes]", classes)

    else
      String.replace(@no_classes, "[date_prefix]", "Today")
    end
  end

  def build_response([], location) do
    date =
      location.timezone
      |> Calendar.Date.today!()

    classes =
      location.id
      |> ClassSchedule.all()
      |> Stream.filter(fn class -> class.date == date end)
      |> Stream.map(&format_schedule/1)
      |> Enum.join("\n")

    if classes != "" do
      @classes
      |> String.replace("[date]", "#{date.month}-#{date.day}-#{date.year}")
      |> String.replace("[classes]", classes)

    else
      String.replace(@no_classes, "[date_prefix]", "Today")
    end
  end

  def build_response(_, location),
    do: location.default_message

  def format_schedule(class) do
    {h, m, _} = Time.to_erl(class.start_time)

    min = if m < 10, do: "0#{m}", else: m

    start_time = cond do
      h == 12 ->
        "#{h}:#{min} PM"
      h > 12 ->
        "#{h-12}:#{min} PM"
      true ->
        "#{h}:#{min} AM"
    end

    "#{start_time} #{class.class_type} (#{class.instructor})"
  end

  defp get_day_of_week({_year, _month, _day} = date, location) do
    with [holiday] <- find_holiday(location, date) do
      {:holiday, holiday}
    else
      _ ->
        {:normal, lookup_day_of_week(date)}
    end
  end

  defp date_prefix({:normal, day_of_week}, {year, month, day}, timezone) do
    date = Calendar.Date.today!(timezone)
    today = lookup_day_of_week({date.year, date.month, date.day})

    if today == day_of_week do
      "today"
    else
      "#{month}/#{day}/#{year}"
    end
  end

  defp lookup_day_of_week(day) do
    {year, month, day} = convert_to_integer(day)
    index = Calendar.ISO.day_of_week(year, month, day) |> Kernel.-(1)
    Enum.at(@days_of_week, index)
  end

  defp convert_to_integer({year, month, day}) do
    {check_binary(year), check_binary(month), check_binary(day)}
  end

  defp check_binary(value) when is_binary(value), do: String.to_integer(value)
  defp check_binary(value) when is_integer(value), do: value

  defp find_holiday(location_id, erl_date) do
    location_id
    |> HolidayHours.get_by_location_id()
    |> Enum.filter(fn d ->
      match_date?(d.holiday_date, erl_date)
    end)
  end

  defp match_date?(nil, _), do: false

  defp match_date?(date, erl_date) do
    Date.to_erl(date) == erl_date
  end
end
