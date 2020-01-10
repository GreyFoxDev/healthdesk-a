defmodule MainWeb.Intents.ClassSchedule do
  @moduledoc """
  This handles class schedule responses
  """

  alias Data.Commands.{
    ClassSchedule,
    Location
  }

  @behaviour MainWeb.Intents

  @classes "[date]:\n[classes]"
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."
  @no_classes "There are no classes scheduled for [date_prefix]. Please ask about a different day."
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  @impl MainWeb.Intents
  def build_response([datetime: {datetime, _}], location),
    do: build_response([datetime: datetime], location)

  def build_response([datetime: datetime], location) do
    location = Location.get_by_phone(location)

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
      {term, day_of_week} = get_day_of_week({year, month, day})

      String.replace(@no_classes, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))
    end
  end

  def build_response(args, location) do
    location = Location.get_by_phone(location)

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

  defp get_day_of_week({year, month, day} = date) do
    with nil <- MainWeb.HolidayDates.is_holiday?(date) do
      {:normal, lookup_day_of_week(date)}
    else
      holiday ->
        {:holiday, holiday}
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

end
