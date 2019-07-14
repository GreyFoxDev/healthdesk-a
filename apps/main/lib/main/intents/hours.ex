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
  def build_response([datetime: {datetime, _}], location),
    do: build_response([datetime: datetime], location)

  def build_response([datetime: datetime], location) do

    location = Location.get_by_phone(location)
    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime

    IO.inspect {year, month, day}, label: "DAY"
    IO.inspect location.id, label: "LOCATION ID"

    with {term, day_of_week} when term in [:holiday, :normal] <- get_day_of_week({year, month, day}, location.id) |> IO.inspect(label: "GET DAY OF WEEK"),
         [hours] <- get_hours(location.id, {term, day_of_week}) |> IO.inspect(label: "GET HOURS") do

      prefix = date_prefix({term, day_of_week}, {year, month, day}, location.timezone)

      @hours
      |> String.replace("[date_prefix]", prefix)
      |> String.replace("[open]", hours.open_at)
      |> String.replace("[close]", hours.close_at)
    else
      [] ->
        {term, day_of_week} = get_day_of_week({year, month, day}, location.id)

        String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))
      _ ->
        @default_response
    end
  end

  def build_response([], location) do
    IO.inspect "ARGS ARE EMPTY"
    location = Location.get_by_phone(location)

    erl_date =
      location.timezone
      |> Calendar.Date.today!()
      |> Calendar.Date.to_erl()

    with {term, day_of_week} when term in [:holiday, :normal] <- get_day_of_week(erl_date, location.id),
         [hours] <- get_hours(location.id, {term, day_of_week}) do

      @hours
      |> String.replace("[date_prefix]", "Today")
      |> String.replace("[open]", hours.open_at)
      |> String.replace("[close]", hours.close_at)
    else
      [] ->
        {term, day_of_week} = get_day_of_week(erl_date, location.id)

      String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, erl_date, location.timezone))
      _ ->
        @default_response
    end
  end

  def build_response(_, _), do: @default_response

  defp get_day_of_week({year, _, _} = day, location) when is_binary(year) do
    day
    |> convert_to_integer()
    |> get_day_of_week(location)
  end

  defp get_day_of_week({year, month, day} = date, location) do
    with [holiday] <- HolidayHours.find(location, date) do
      {:holiday, holiday}
    else
      _ ->
        {:normal, lookup_day_of_week(date)}
    end
  end

  defp get_hours(location, {:normal, day_of_week}) do
    location
    |> NormalHours.all()
    |> Enum.filter(fn hour -> hour.day_of_week == day_of_week end)
  end

  defp get_hours(_location, {:holiday, holiday}) do
    [holiday]
  end

  defp date_prefix(term, day, timezone \\ "PST8PDT")

  defp date_prefix(term, {year, _, _} = day, timezone) when is_binary(year) do
    erl_date = convert_to_integer(day)
    date_prefix(term, erl_date, timezone)
  end

  defp date_prefix({_term, day_of_week}, {year, month, day}, timezone) do
    date = Calendar.Date.today!(timezone)
    today = lookup_day_of_week({date.year, date.month, date.day})

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
