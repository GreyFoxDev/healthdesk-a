defmodule MainWeb.Intents.InstructorSchedule do
  @moduledoc """
  This handles instructor schedule responses
  """

  alias Main.Integrations.Mindbody
  alias Data.{
    ClassSchedule,
    Location
  }

  @behaviour MainWeb.Intents

  @keys [:instructor]
  @no_classes "It doesn't look like we have an instructor here by that name. (Please ensure correct spelling)"
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  @impl MainWeb.Intents
  def build_response(args, location) when is_binary(location),
    do: build_response(args, Location.get_by_phone(location))

  def build_response([instructor: [%{"value" => instructor}]], %{mindbody_location_id: mb_id} = location) when mb_id not in [nil, ""] do
    now = Calendar.DateTime.now!(location.timezone)
    date = Calendar.Date.from_erl!({now.year, now.month, now.day})
    time = Calendar.Time.from_erl!({now.hour, now.minute, 0})

    start_date =
      location.timezone
      |> Calendar.Date.today!()
      |> to_string()

    end_date =
      location.timezone
      |> Calendar.Date.today!()
      |> Calendar.Date.add!(7)
      |> to_string()

    class =
      location
      |> Mindbody.get_classes(start_date, end_date)
      |> Enum.find(&find_classes(&1, date, time, instructor))
      |> format_schedule()

    (class || @no_classes)
  end

  def build_response([instructor: [%{"value" => instructor}]], location) do
    now = Calendar.DateTime.now!(location.timezone)
    date = Calendar.Date.from_erl!({now.year, now.month, now.day})
    time = Calendar.Time.from_erl!({now.hour, now.minute, 0})

    class =
      location.id
      |> ClassSchedule.all()
      |> Enum.find(&find_classes(&1, date, time, instructor))
      |> format_schedule()

    (class || @no_classes)
  end

  def build_response(_args, location),
    do: location.default_message

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

  defp find_classes(class, date, time, instructor) do
    with class_instructor <- String.downcase(class.instructor),
         true <- String.contains?(class_instructor, String.downcase(instructor)),
         true <- class.date >= date do

      if class.date == date do
        class.start_time > time
      else
        true
      end
    end
  end
end
