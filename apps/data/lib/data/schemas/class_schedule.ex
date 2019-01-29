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
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
