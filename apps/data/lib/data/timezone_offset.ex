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

  def calculate(<<_::binary-size(3), hour::binary-size(1), _::binary>> = timezone)
      when timezone in @timezones do
    hour
    |> String.to_integer()
#    |> Kernel.-(1) # Temp because of daylight savings
    |> Kernel.*(-3600)
  end

  def calculate(_), do: 0
end
