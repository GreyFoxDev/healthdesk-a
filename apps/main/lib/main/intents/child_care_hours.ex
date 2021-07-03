defmodule MainWeb.Intents.ChildCareHours do
  @moduledoc """
  This handles child care hours message responses
  """

  alias Data.{
    ChildCareHours,
    Location
    }

  @behaviour MainWeb.Intents

  @all_hours "Our child care hours are:\n[schedule]"
  @hours "[date_prefix], our child care hours are [morning_open] to [morning_close]."
  @afternoon_hours " and [afternoon_open] to [afternoon_close]."
  @closed "[date_prefix], our child care is closed."
  @no_child_care "Unfortunately, we don't offer child care."
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."

  @impl MainWeb.Intents
  def build_response([datetime: datetime], location) do
    location = Location.get_by_phone(location)
    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime

    with {:normal, day_of_week} <- get_day_of_week({year, month, day},location),
         [hours] <- get_hours(location.id, {:normal, day_of_week}) do

      prefix = date_prefix({:normal, day_of_week}, {year, month, day}, location.timezone)

      response =
        @hours
        |> String.replace("[date_prefix]", prefix)
        |> String.replace("[morning_open]", hours.morning_open_at)
        |> String.replace("[morning_close]", hours.morning_close_at)

      response = if hours.afternoon_open_at do
        response
        |> String.replace(".", @afternoon_hours)
        |> String.replace("[afternoon_open]", hours.afternoon_open_at)
        |> String.replace("[afternoon_close]", hours.afternoon_close_at)
      else
        response
      end

      response

    else
      {:holiday, holiday} ->
        "#{holiday} might affect the child care hours so best to call #{location.phone_number}"

      :no_child_care ->
        @no_child_care

      [] ->
        {term, day_of_week} = get_day_of_week({year, month, day},location)

        String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))
      _ ->
        if location.default_message != "" do
          location.default_message
        else
          @default_response
        end
    end
  end

  def build_response(_intent, location) do
    location = Location.get_by_phone(location)

    with [] <- get_hours(location.id) do
      @no_child_care
    else
      hours ->
        schedule =
          hours
          |> Stream.map(&format_schedule/1)
          |> Enum.join("\n")

        String.replace(@all_hours, "[schedule]", schedule)
    end
  end

  defp get_day_of_week({_year, _month, _day} = date,location) do
    with [holiday] <- find_holiday(location, date) do
      {:holiday, holiday}
    else
      _ ->
        {:normal, lookup_day_of_week(date)}
    end
  end

  defp format_schedule(%{afternoon_open_at: nil} = day) do
    "#{day.day_of_week}: #{day.morning_open_at} to #{day.morning_close_at}"
  end

  defp format_schedule(%{times: []}=_day) do
    ""
  end
  defp format_schedule(%{times: times}=day) do
    {morning,evening} = times |> Enum.reduce({[],[]},fn b, {morning,evening} -> {[(b.morning_open_at <> " to " <> b.morning_close_at) | morning], [(b.afternoon_open_at <> " to " <> b.afternoon_close_at) | evening]}end)
    morning = morning |> Enum.join(",")
    evening = evening |> Enum.join(",")
    "#{day.day_of_week}: morning(#{morning}) and afternoon(#{evening})"
  end

  defp get_hours(location) do
    ChildCareHours.all(%{role: "admin"}, location)
  end

  defp get_hours(location, {:normal, day_of_week}) do
    %{role: "admin"}
    |> ChildCareHours.all(location)
    |> filter_hours(day_of_week)
  end

  defp filter_hours([], _) do
    :no_child_care
  end

  defp filter_hours(hours, day_of_week) do
    Enum.filter(hours, fn hour -> hour.day_of_week == day_of_week end)
  end

  defp date_prefix({:normal, day_of_week}, {year, month, day}, timezone \\ "PST8PDT") do
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

  defp find_holiday(location_id, erl_date) do
    location_id
    |> HolidayHours.get_by_location_id()
    |> Enum.filter(fn d ->
      match_date?(d.holiday_date, erl_date)
    end)
  end
  defp match_date?(nil, _), do: false

  defp match_date?(date, erl_date) do
    Date.to_erl(date) == erl_date
  end

end
