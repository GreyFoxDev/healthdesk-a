defmodule Data.Schema.ChildCareHour do
  @moduledoc """
  The schema for a location's child care hours
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          day_of_week: String.t() | nil,
          morning_open_at: String.t() | nil,
          morning_close_at: String.t() | nil,
          afternoon_open_at: String.t() | nil,
          afternoon_close_at: String.t() | nil,
          active: boolean() | nil,
          deleted_at: :utc_datetime | nil
        }

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
