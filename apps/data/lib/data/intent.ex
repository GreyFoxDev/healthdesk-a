defmodule Data.Intent do

  alias Data.Commands.{
    Location,
    NormalHours,
    WifiNetwork,
    PricingPlan,
    ChildCareHours
  }

  @default_error "Not sure about that. Give me a minute..."

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
         hours <- NormalHours.all(l.id),
         [hours] <- Enum.filter(hours, fn(hour) -> hour.day_of_week == args end)
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

end
