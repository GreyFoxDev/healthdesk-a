defmodule MainWeb.Intents.ClassNext do
  @moduledoc """
  This handles class schedule responses
  """

  alias Data.{
    ClassSchedule,
    Location
  }

  @behaviour MainWeb.Intents
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."
  @no_classes "It doesn't look like we have an instructor here by that name. (Please ensure correct spelling)"
  @days_of_week ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  @impl MainWeb.Intents
  def build_response([class_type: [%{"value" => class_type}]], location) do
    location = Location.get_by_phone(location)
    now = Calendar.DateTime.now!(location.timezone)
    date = Calendar.Date.from_erl!({now.year, now.month, now.day})
    time = Calendar.Time.from_erl!({now.hour, now.minute, 0})

    class =
      location.id
      |> ClassSchedule.all()
      |> Enum.find(&find_classes(&1, date, time, class_type))
      |> format_schedule()

    (class || @no_classes)
  end

  def build_response(_args, _location),
    do: @default_response

  defp format_schedule(nil), do: nil
  defp format_schedule(class) do
    day_of_week = lookup_day_of_week(class.date)

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

    "#{class.instructor}:\n#{day_of_week} #{start_time} #{class.class_type}"
  end

  defp lookup_day_of_week(day) do
    index = Calendar.ISO.day_of_week(day.year, day.month, day.day) |> Kernel.-(1)
    Enum.at(@days_of_week, index)
  end

  defp find_classes(class, date, time, class_type) do
    with type <- String.downcase(class.class_type),
         true <- String.contains?(type, String.downcase(class_type)),
         true <- class.date >= date do
      if class.date == date do
        class.start_time > time
      else
        true
      end
    end
  end
end
