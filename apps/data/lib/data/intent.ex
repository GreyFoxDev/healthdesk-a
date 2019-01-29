defmodule Data.Intent do
  alias Data.Commands.{
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

  def get_message({"getDayPass", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         plans <- PricingPlan.all(l.id),
         [%{daily: daily}] <- Enum.filter(plans, &(&1.has_daily == true)) do
      "Day passes are #{daily}"
    else
      _ ->
        "Unfortunately, we don't offer a day pass."
    end
  end

  def get_message({"getWeekPass", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         plans <- PricingPlan.all(l.id),
         [%{weekly: weekly}] <- Enum.filter(plans, &(&1.has_weekly == true)) do
      "Week passes are #{weekly}"
    else
      _ ->
        "Unfortunately, we don't offer a week pass."
    end
  end

  def get_message({"getMonthPass", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         plans <- PricingPlan.all(l.id),
         [%{monthly: monthly}] <- Enum.filter(plans, &(&1.has_monthly == true)) do
      "Month passes are #{monthly}"
    else
      _ ->
        "Unfortunately, we don't offer a month pass."
    end
  end

  def get_message({"getMessageGeneric", "thanks"}, _phone_number) do
    "No sweat!"
  end

  def get_message({"getAddress", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number) do
      address =
        [l.address_1, l.address_2, "#{l.city},", l.state, l.postal_code]
        |> Enum.join(" ")

      "We are located at #{address}"
    else
      nil ->
        @default_error
    end
  end

  def get_message({"getChildCareHours", args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         {_, day} = day_of_week <- convert_to_day(args),
         hours <- ChildCareHours.all(l.id),
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

  def get_message({"getWifi", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         [wifi] <- WifiNetwork.all(l.id) do
      ["Here's the Wifi Info\nNetwork: ", wifi.network_name, " Password: ", wifi.network_pword]
      |> Enum.join()
    else
      _ ->
        "Unfortunately, we don't offer free WiFi."
    end
  end

  def get_message({"queryInstructorSchedule",  args}, phone_number) do
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
  def handle_classes(classes, [instructor: instructor, class_type: class_type, datetime: datetime]) do
    date = Date.from_iso8601!(datetime)

    Enum.filter(classes, fn(class) ->
      class.instructor == instructor &&
        class.class_type == class_type &&
        class.date == date
    end)
  end

  def handle_classes(classes, [instructor: instructor, class_type: class_type]) do
    Enum.filter(classes, fn(class) ->
      class.instructor == instructor && class.class_type == class_type
    end)
  end

  def handle_classes(classes, [class_category: category, datetime: datetime]) do
    date = Date.from_iso8601!(datetime)

    Enum.filter(classes, fn(class) ->
        class.class_category == category && class.date == date
    end)
  end

  def handle_classes(classes, [class_category: category]) do
    Enum.filter(classes, fn(class) -> class.category == category end)
  end

  def handle_classes(classes, [instructor: instructor]) do
    Enum.filter(classes, fn(class) -> class.instructor == instructor end)
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
    |> HolidayHours.all()
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
