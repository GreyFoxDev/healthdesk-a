defmodule MainWeb.Intents.Hours do

  alias Data.{
    HolidayHours,
    NormalHours,
    Location
    }

  @behaviour MainWeb.Intents
  @string "[open] to [close]"
  @hours "[date_prefix], our hours are [hours]. Is there anything else we can assist you with?"
  @closed "[date_prefix], we are closed. Is there anything else we can assist you with?"
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."
  @alt_response "Members have 24/7 keycard access. [date_prefix], our staff hours are [hours]. Is there anything else we can assist you with?"


  @impl MainWeb.Intents
  def build_response([datetime: {datetime, _}], location),
      do: build_response([datetime: datetime], location)

  def build_response([datetime: datetime], location) do

    case Location.get_by_phone(location) do
      %Data.Schema.Location{} = location ->
    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime


    with {term, day_of_week} when term in [:holiday, :normal] <- get_day_of_week({year, month, day}, location.id),
         [hours] <- get_hours(location.id, {term, day_of_week}) do

      prefix = date_prefix({term, day_of_week}, {year, month, day}, location.timezone)

      if(hours.closed == false) do
        if length(hours.times) do
          times =
            hours.times
            |> Enum.reduce([],fn b,acc ->[(b.open_at<>" to "<>b.close_at)|acc] end)
            |> Enum.join(" and ")

          if location.team.team_name in ["92nd Street Y", "10 Fitness"] do
            @alt_response
            |> String.replace("[date_prefix]", prefix)
            |> String.replace("[hours]", times)

          else
            @hours
            |> String.replace("[date_prefix]", prefix)
            |> String.replace("[hours]", times)

          end
        else
          String.replace(@closed, "[data_prefix]", prefix)
        end

        else
        if length(hours.times) do
          times =
            hours.times
            |> Enum.reduce([],fn b,acc ->[(b.open_at<>" to "<>b.close_at)|acc] end)
            |> Enum.join(" and ")

          if location.team.team_name in ["92nd Street Y", "10 Fitness"] do
            @alt_response
            |> String.replace("[date_prefix]", prefix)
            |> String.replace("[hours]", times)

          else
            {term, day_of_week} = get_day_of_week({year, month, day}, location.id)

            String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))

          end
        else
          String.replace(@closed, "[data_prefix]", prefix)
        end
      end

    else
      [] ->
        {term, day_of_week} = get_day_of_week({year, month, day}, location.id)

        String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, {year, month, day}, location.timezone))

      _ ->
        if location.default_message != "" do
          location.default_message
        else
          @default_response
        end
    end

    nil -> nil
  end
end
  def build_response([], location) do

    case Location.get_by_phone(location) do
      %Data.Schema.Location{} = location ->
        erl_date =
          location.timezone
          |> Calendar.Date.today!()
          |> Calendar.Date.to_erl()

        with {term, day_of_week} when term in [:holiday, :normal] <- get_day_of_week(erl_date, location.id),
             [hours] <- get_hours(location.id, {term, day_of_week}) do

          if length(hours.times) do
            times =
              hours.times
              |> Enum.reduce([],fn b,acc ->[(b.open_at<>" to "<>b.close_at)|acc] end)
              |> Enum.join(" and ")
            if location.team.team_name in ["92nd Street Y", "10 Fitness"] do
              @alt_response
              |> String.replace("[date_prefix]", "Today")
              |> String.replace("[hours]", times)
            else
              @hours
              |> String.replace("[date_prefix]", "Today")
              |> String.replace("[hours]", times)
            end
          else
            String.replace(@closed, "[data_prefix]", "Today")
          end
        else
          [] ->
            {term, day_of_week} = get_day_of_week(erl_date, location.id)

            String.replace(@closed, "[date_prefix]", date_prefix({term, day_of_week}, erl_date, location.timezone))
          _ ->
            if location.default_message != "" do
              location.default_message
            else
              @default_response
            end
        end

      nil -> nil

    end

  end

  def build_response(wtf, location) do
    case wtf[:datetime] do
      nil ->

        case Location.get_by_phone(location) do
          %Data.Schema.Location{} = location ->
            if location.default_message != "" do
              location.default_message
            else
              @default_response
            end

          nil -> nil
        end

      datetime -> build_response([datetime: datetime], location)

    end
  end

  defp get_day_of_week({year, _, _} = day, location) when is_binary(year) do
    day
    |> convert_to_integer()
    |> get_day_of_week(location)
  end

  defp get_day_of_week({_year, _month, _day} = date, location) do
    with [holiday] <- find_holiday(location, date) do
      {:holiday, holiday}
    else
      _ ->
        {:normal, lookup_day_of_week(date)}
    end
  end

  defp get_hours(location, {:normal, day_of_week}) do
    location
    |> NormalHours.get_by_location_id()
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

  def find_holiday(location_id, erl_date) do
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
