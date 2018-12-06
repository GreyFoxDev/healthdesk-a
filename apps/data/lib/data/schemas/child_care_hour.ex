defmodule Data.Schema.ChildCareHour do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  day_of_week
  morning_open_at
  morning_close_at
  afternoon_open_at
  afternoon_close_at
  active
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "child_care_hours" do
    field(:day_of_week, :string)
    field(:morning_open_at, :string)
    field(:morning_close_at, :string)
    field(:afternoon_open_at, :string)
    field(:afternoon_close_at, :string)
    field(:active, :boolean)

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
