defmodule Data.Schema.ClassSchedule do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  date
  start_time
  end_time
  instructor
  class_type
  class_category
  class_description
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "class_schedules" do
    field(:date, :date)
    field(:start_time, :time)
    field(:end_time, :time)

    field(:instructor, :string)
    field(:class_type, :string)
    field(:class_category, :string)
    field(:class_description, :string)

    belongs_to(:location, Data.Schema.Location)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    params =
      params
      |> clean_date()
      |> clean_times()

    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  defp clean_date(%{"date" => date} = params) do
    fmt =
      case date do
        <<m::binary-size(1), "/", d::binary-size(1), "/", y::binary-size(4)>> ->
          "#{y}-0#{m}-0#{d}"

        <<m::binary-size(1), "/", d::binary-size(2), "/", y::binary-size(4)>> ->
          "#{y}-0#{m}-#{d}"

        <<m::binary-size(2), "/", d::binary-size(1), "/", y::binary-size(4)>> ->
          "#{y}-#{m}-0#{d}"

        <<m::binary-size(2), "/", d::binary-size(2), "/", y::binary-size(4)>> ->
          "#{y}-#{m}-#{d}"

        date ->
          date
      end

    Map.merge(params, %{"date" => fmt})
  end

  defp clean_date(params), do: params

  defp clean_times(%{"start_time" => start_time, "end_time" => end_time} = params) do
    Map.merge(params, %{"start_time" => adjust_time(start_time), "end_time" => adjust_time(end_time)})
  end

  defp adjust_time(time) do
    [hr,  << min::binary-size(2), " ", am_pm::binary-size(2)>>]  = String.split(time, ":")

    min = String.to_integer(min)

    hr = if am_pm == "AM" do
      String.to_integer(hr)
    else
      hr = String.to_integer(hr)
      if hr < 12 do
        hr + 12
      else
        hr
      end
    end

    Calendar.Time.from_erl!({hr, min, 0})
  end

  defp clean_times(params), do: params
end
