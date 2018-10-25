defmodule Data.Schema.HolidayHour do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  holiday_name
  holiday_date
  open_at
  close_at
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "holiday_hours" do
    field(:holiday_name, :string)
    field(:holiday_date, :utc_datetime)
    field(:open_at, :string)
    field(:close_at, :string)

    field(:deleted_at, :utc_datetime)

    belongs_to(:location, Data.Schema.Location)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
