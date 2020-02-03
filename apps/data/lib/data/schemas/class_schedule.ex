defmodule Data.Schema.ClassSchedule do
  @moduledoc """
  The schema for a location's class schedule
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          date: Data.t() | nil,
          start_time: String.t() | nil,
          end_time: String.t() | nil,
          instructor: String.t() | nil,
          class_type: String.t() | nil,
          class_category: String.t() | nil,
          class_description: String.t() | nil
        }

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

  defp clean_date(%{"date" => date} = params),
    do: Map.put(params, "date", format_date(date))

  defp clean_date(%{date: date} = params),
    do: Map.put(params, :date, format_date(date))

  defp clean_date(params),
    do: params

  defp format_date(<<m::binary-size(1), "/", d::binary-size(1), "/", y::binary-size(4)>>),
    do: "#{y}-0#{m}-0#{d}"

  defp format_date(<<m::binary-size(1), "/", d::binary-size(2), "/", y::binary-size(4)>>),
    do: "#{y}-0#{m}-#{d}"

  defp format_date(<<m::binary-size(2), "/", d::binary-size(1), "/", y::binary-size(4)>>),
    do: "#{y}-#{m}-0#{d}"

  defp format_date(<<m::binary-size(2), "/", d::binary-size(2), "/", y::binary-size(4)>>),
    do: "#{y}-#{m}-#{d}"

  defp format_date(date), do: date

  defp clean_times(%{start_time: start_time, end_time: end_time} = params) do
    Map.merge(params, %{
      start_time: adjust_time(start_time),
      end_time: adjust_time(end_time)
    })
  end

  defp clean_times(%{"start_time" => start_time, "end_time" => end_time} = params) do
    Map.merge(params, %{
      "start_time" => adjust_time(start_time),
      "end_time" => adjust_time(end_time)
    })
  end

  defp clean_times(params), do: params

  defp adjust_time(time) do
    [hr, <<min::binary-size(2), " ", am_pm::binary-size(2)>>] = String.split(time, ":")

    min = String.to_integer(min)

    hr =
      if am_pm == "AM" do
        String.to_integer(hr)
      else
        hr = String.to_integer(hr)

        if hr < 12 do
          hr + 12
        else
          hr - 12
        end
      end

    Time.from_erl!({hr, min, 0})
  end
end
