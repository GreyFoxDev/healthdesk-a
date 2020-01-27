defmodule Data.Intent do
  alias Data.{
    Location,
    NormalHours,
    HolidayHours,
    WifiNetwork,
    PricingPlan,
    ChildCareHours,
    ClassSchedule
  }

  @default_error "Not sure about that. Give me a minute..."
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  def get_message({"getChildCareHours", args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         {_, day} <- convert_to_day(args),
         hours <- ChildCareHours.get_by_location_id(l.id),
         [hours] <- Enum.filter(hours, fn hour -> hour.day_of_week == day end) do
      [
        "Morning hours are: #{hours.morning_open_at} - #{hours.morning_close_at}\n",
        "Afternoon hours are: #{hours.afternoon_open_at} - #{hours.afternoon_close_at}"
      ]
      |> Enum.join()
    else
      _ ->
        @default_error
    end
  end

  def get_message({"getHours", args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         {_, day} = day_of_week <- convert_to_day(args),
         [hours] <- get_hours(l, day_of_week) do
      "On #{day}, the hours are #{hours.open_at} to #{hours.close_at}"
    else
      _ ->
        @default_error
    end
  end

  def get_message({"queryInstructorSchedule", args}, phone_number) do
    phone_number
    |> get_classes()
    |> handle_classes(args)
  end

  def get_message({"queryClassNext", args}, phone_number) do
    phone_number
    |> get_classes()
    |> handle_classes(args)
  end

  def get_message({:unknown, _args}, _), do: @default_error

  def get_classes(phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number) do
      ClassSchedule.all(l.id)
    else
      _ -> []
    end
  end

  def handle_classes([], _), do: "Unfortunately, we don't offer any classes"

  def handle_classes(classes, instructor: instructor, class_type: class_type, datetime: datetime) do
    date = Date.from_iso8601!(datetime)

    Enum.filter(classes, fn class ->
      class.instructor == instructor &&
        class.class_type == class_type &&
        class.date == date
    end)
  end

  def handle_classes(classes, instructor: instructor, class_type: class_type) do
    Enum.filter(classes, fn class ->
      class.instructor == instructor && class.class_type == class_type
    end)
  end

  def handle_classes(classes, class_category: category, datetime: datetime) do
    date = Date.from_iso8601!(datetime)

    Enum.filter(classes, fn class ->
      class.class_category == category && class.date == date
    end)
  end

  def handle_classes(classes, class_category: category) do
    Enum.filter(classes, fn class -> class.category == category end)
  end

  def handle_classes(classes, instructor: instructor) do
    Enum.filter(classes, fn class -> class.instructor == instructor end)
  end

  defp convert_to_day(
         <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2),
           _rest::binary>>
       ) do
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
    |> get_day_of_week()
  end

  defp get_hours(location, {:normal, day_of_week}) do
    location.id
    |> NormalHours.all()
    |> Enum.filter(fn hour -> hour.day_of_week == day_of_week end)
  end

  defp get_hours(location, {:holiday, holiday}) do
    location.id
    |> HolidayHours.get_by_location_id()
    |> Enum.filter(fn hour -> hour.holiday_name == holiday end)
  end

  defp get_day_of_week({_year, 12, 25}), do: {:holiday, "Christmas"}
  defp get_day_of_week({_year, 12, 31}), do: {:holiday, "New Year's Eve"}
  defp get_day_of_week({_year, 1, 1}), do: {:holiday, "New Year's Day"}
  defp get_day_of_week({_year, 7, 4}), do: {:holiday, "4th of July"}

  defp get_day_of_week({year, month, day}) do
    index = Calendar.ISO.day_of_week(year, month, day) |> Kernel.-(1)
    {:normal, Enum.at(@days_of_week, index)}
  end
end
