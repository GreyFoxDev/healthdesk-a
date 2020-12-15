defmodule MainWeb.HolidayHourView do
  use MainWeb, :view

  def format_short_date(datetime) do

    Calendar.DateTime.to_date(datetime)
  end
end
