defmodule Data.Schema.NormalHour do
  @moduledoc """
  The schema for a location's normal hours
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          day_of_week: String.t() | nil,
          open_at: String.t() | nil,
          close_at: String.t() | nil,
          active: boolean() | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  day_of_week
  open_at
  close_at
  active
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "normal_hours" do
    field(:day_of_week, :string)
    field(:open_at, :string)
    field(:close_at, :string)

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
