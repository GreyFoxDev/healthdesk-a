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
    params = clean_date(params)

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

    Map.merge(params, %{"date" => fmt}) |> IO.inspect()
  end

  defp clean_date(params), do: params
end
