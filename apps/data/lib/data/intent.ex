defmodule Data.Intent do

  alias Data.Commands.{
    Location,
    NormalHours,
    HolidayHours,
    WifiNetwork,
    PricingPlan,
    ChildCareHours
  }

  @default_error "Not sure about that. Give me a minute..."
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  def get_message({"getDayPass", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         plans <- PricingPlan.all(l.id),
           [%{daily: daily}] <- Enum.filter(plans, &(&1.has_daily == true))
      do
      daily
      else
        _ ->
          @default_error
    end
  end

  def get_message({"getWeekPass", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         plans <- PricingPlan.all(l.id),
           [%{weekly: weekly}] <- Enum.filter(plans, &(&1.has_weekly == true))
      do
      weekly
      else
        _ ->
          @default_error
    end
  end

  def get_message({"getMonthPass", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         plans <- PricingPlan.all(l.id),
           [%{monthly: monthly}] <- Enum.filter(plans, &(&1.has_monthly == true))
      do
      monthly
      else
        _ ->
          @default_error
    end
  end

  def get_message({"getAddress", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number) do
      [l.address_1, l.address_2, "#{l.city},", l.state, l.postal_code]
      |> Enum.join(" ")
    else
      nil ->
        @default_error
    end
  end

  def get_message({"getChildCareHours", args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         hours <- ChildCareHours.all(l.id),
           [hours] <- Enum.filter(hours, fn(hour) -> hour.day_of_week == args end)
      do
      [
        "Morning hours are: #{hours.morning_open_at} - #{hours.morning_close_at}\n",
        "Afternoon hours are: #{hours.afternoon_open_at} - #{hours.afternoon_close_at}"
      ] |> Enum.join
      else
        _ ->
          @default_error
    end
  end

  def get_message({"getHours", args}, phone_number) do

    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         day_of_week <- convert_to_day(args),
         [hours] <- get_hours(l, day_of_week)
      do
        [hours.open_at, hours.close_at] |> Enum.join(" - ")
      else
        _ ->
          @default_error
    end
  end

  def get_message({"getWifi", _args}, phone_number) do
    with %Data.Schema.Location{} = l <- Location.get_by_phone(phone_number),
         [wifi] <- WifiNetwork.all(l.id)
      do
      ["Network: ", wifi.network_name, " Password: ", wifi.network_pword] |> Enum.join()
      else
        _ ->
          @default_error
    end
  end

  defp convert_to_day(<< year :: binary-size(4), "-", month :: binary-size(2), "-", day :: binary-size(2), _rest :: binary >>) do
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)} |> get_day_of_week()
  end

  defp get_hours(location, {:normal, day_of_week}) do
    location.id
    |> NormalHours.all()
    |> Enum.filter(fn(hour) -> hour.day_of_week == day_of_week end)
  end

  defp get_hours(location, {:holiday, holiday}) do
    location.id
    |> HolidayHours.all()
    |> Enum.filter(fn(hour) -> hour.holiday_name == holiday end)
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
