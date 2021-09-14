defmodule Data.TimezoneOffset do
  @moduledoc """
  This module calculates the timezone offset in seconds
  """
  @timezones [
    "PST8PDT",
    "MST7MDT",
    "CST6CDT",
    "EST5EDT"
  ]

  def calculate(<<_::binary-size(3), _hour::binary-size(1), _::binary>> = timezone)
      when timezone in @timezones do
    tz = Timex.timezone(timezone, Date.utc_today())
    Timex.Timezone.total_offset(tz)
  end

  def calculate(_), do: 0
end
