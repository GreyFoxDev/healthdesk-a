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

end

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
  @default_response "I'm checking with a teammate for assistance. One moment please..."

  @impl MainWeb.Intents
  def build_response([datetime: datetime], location) do
    location = Location.get_by_phone(location)
    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime

    with {term, day_of_week} when term in [:holiday, :normal] <- get_day_of_week({year, month, day}),
         [hours] <- get_hours(location.id, {term, day_of_week}) do

      prefix = date_prefix({term, day_of_week}, {year, month, day})

      @hours
      |> String.replace("[date_prefix]", prefix)
      |> String.replace("[open]", hours.open_at)
      |> String.replace("[close]", hours.close_at)
    else
      [] ->
        {term, day_of_week} = get_day_of_week({year, month, day})

        String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}))
      _ ->
        @default_response
    end
  end

  def build_response(_, _), do: @default_response

  defp get_day_of_week({year, month, day} = date) do
    with nil <- MainWeb.HolidayDates.is_holiday?(date) do
      {:normal, lookup_day_of_week(date)}
    else
      holiday ->
        {:holiday, holiday}
    end
  end

  defp get_hours(location, {:normal, day_of_week}) do
    location
    |> NormalHours.all()
    |> Enum.filter(fn hour -> hour.day_of_week == day_of_week end)
  end

  defp get_hours(location, {:holiday, holiday}) do
    location
    |> HolidayHours.all()
    |> Enum.filter(fn hour -> hour.holiday_name == holiday end)
  end

  defp date_prefix({:normal, day_of_week}, {year, month, day}) do
    date = Calendar.Date.today!("PST8PDT")
    today = lookup_day_of_week({date.year, date.month, date.day})

    IO.inspect today, label: "TODAY"
    IO.inspect day_of_week, label: "DAY OF WEEK"

    if today == day_of_week do
      "Today"
    else
      "On #{month}/#{day}/#{year}"
    end
  end

  defp lookup_day_of_week(day) do
    {year, month, day} = convert_to_integer(day)
    index = Calendar.ISO.day_of_week(year, month, day) |> Kernel.-(1)
    Enum.at(@days_of_week, index)
  end

  defp convert_to_integer({year, month, day}) do
    {check_binary(year), check_binary(month), check_binary(day)}
  end

  defp check_binary(value) when is_binary(value), do: String.to_integer(value)
  defp check_binary(value) when is_integer(value), do: value
end
