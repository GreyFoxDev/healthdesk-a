defmodule Data.Schema.ChildCareHour do
  @moduledoc """
  The schema for a location's child care hours
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          day_of_week: String.t() | nil,
          active: boolean() | nil,
          closed: boolean() | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  day_of_week
  active
  closed
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "child_care_hours" do
    field(:day_of_week, :string)
    field(:active, :boolean)
    field(:closed, :boolean)

    field(:deleted_at, :utc_datetime)

    belongs_to(:location, Data.Schema.Location)

    embeds_many :times, Times, on_replace: :delete do
      field(:morning_open_at, :string)
      field(:morning_close_at, :string)
      field(:afternoon_open_at, :string)
      field(:afternoon_close_at, :string)
    end

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def update_changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> cast_embed(:times, with: &times_changeset/2)
    |> validate_required(@required_fields)
  end

  defp times_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:morning_open_at, :morning_close_at, :afternoon_open_at, :afternoon_close_at])
  end
end
