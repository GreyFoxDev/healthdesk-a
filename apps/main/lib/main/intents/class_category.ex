defmodule MainWeb.Intents.ClassCategory do
  @moduledoc """
  This handles class schedule responses
  """

  alias Data.Commands.{
    ClassSchedule,
    Location
  }

  @behaviour MainWeb.Intents

  @classes "[category]:\n[classes]"
  @default_response "During normal business hours, someone from our staff will be with you shortly. If this is during off hours, we will reply the next business day."
  @no_classes "It doesn't look like we have a class category by that name. (Please ensure correct spelling)"
  @days_of_week ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

  @impl MainWeb.Intents
  def build_response([class_category: [%{"value" => category}], datetime: datetime], location) do
    location = Location.get_by_phone(location)

    <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), _rest::binary>> = datetime

    date =
    {year, month, day}
    |> convert_to_integer()
    |> Calendar.Date.from_erl!()

    classes =
      location.id
      |> ClassSchedule.all()
      |> Stream.filter(&find_classes(&1, date, category))
      |> Stream.uniq_by(&(&1.class_type))
      |> Stream.map(&(&1.class_type))
      |> Enum.join("\n")

    if classes != "" do
      @classes
      |> String.replace("[category]", String.upcase(category))
      |> String.replace("[classes]", classes)

    else
      @no_classes
    end
  end

  def build_response([class_category: [%{"value" => category}]], location) do
    location = Location.get_by_phone(location)

    classes =
      location.id
      |> ClassSchedule.all()
      |> Stream.filter(&find_classes(&1, category))
      |> Stream.uniq_by(&(&1.class_type))
      |> Stream.map(&(&1.class_type))
      |> Enum.join("\n")

    if classes != "" do
      @classes
      |> String.replace("[category]", String.capitalize(category))
      |> String.replace("[classes]", classes)

    else
      @no_classes
    end
  end

  def build_response(_args, _location),
    do: @default_response

  defp find_classes(class, date, category) do
    with true <- class.date == date,
         class_cat <- String.downcase(class.class_category()),
         true <- String.contains?(class_cat, String.downcase(category)) do
      true
    end
  end

  defp find_classes(class, category) do
    with class_cat <- String.downcase(class.class_category()),
         true <- String.contains?(class_cat, String.downcase(category)) do
      true
    end
  end

  defp convert_to_integer({year, month, day}) do
    {check_binary(year), check_binary(month), check_binary(day)}
  end

  defp check_binary(value) when is_binary(value), do: String.to_integer(value)
  defp check_binary(value) when is_integer(value), do: value
end
