defmodule MainWeb.Intents.Hours do
  @moduledoc """

  """

  alias Data.Commands.{
    HolidayHours,
    NormalHours,
    Location
  }

  @behaviour MainWeb.Intents

  @hours "[date_prefix], our hours are [open] to [close]."
  @closed "[date_prefix], we are closed."
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  @impl MainWeb.Intents
  def build_response([datetime: datetime], location) do
    location = Location.get_by_phone(location)

    with <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> <- datetime,
         {year, month, day} <- convert_to_integer(year, month, day),
         {term, day} when term in [:holiday, :normal] <- get_day_of_week({year, month, day}),
         [hours] <- get_hours(location.id, {term, day}) do

    else
      _ ->
        "Not sure about that. Give me a minute..."
    end
  end

  defp get_day_of_week({_year, 12, 25}), do: {:holiday, "Christmas"}
  defp get_day_of_week({_year, 12, 31}), do: {:holiday, "New Year's Eve"}
  defp get_day_of_week({_year, 1, 1}), do: {:holiday, "New Year's Day"}
  defp get_day_of_week({_year, 7, 4}), do: {:holiday, "4th of July"}

  defp get_day_of_week({year, month, day}) do
    index = Calendar.ISO.day_of_week(year, month, day) |> Kernel.-(1)
    {:normal, Enum.at(@days_of_week, index)}
  end

  defp convert_to_integer(year, month, day) do
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
  end

  defp get_hours(location, {:normal, day_of_week}) do
    location
    |> NormalHours.all()
    |> Enum.filter(fn hour -> hour.day_of_week == day_of_week end)
  end

  defp get_hours(location, {:holiday, holiday}) do
    location
    |> HoliayHours.all()
    |> Enum.filter(fn hour -> hour.holiday_name == holiday end)
  end
end
