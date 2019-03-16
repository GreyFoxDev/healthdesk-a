defmodule MainWeb.HolidayDates do

  @dates %{
    {2019, 5, 17} => "Memorial Day",
    {2019, 7, 4} => "4th of July",
    {2019, 8, 2} => "Labor Day",
    {2019, 12, 25} => "Christmas",
    {2019, 12, 31} => "New Year's Eve",
    {2020, 1, 1} => "New Year's Day",
  }

  def is_holiday?(date), do: @dates[date]

  def holiday_names, do: Map.values(@dates)

end
