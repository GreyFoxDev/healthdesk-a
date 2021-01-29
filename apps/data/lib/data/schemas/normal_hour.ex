defmodule Data.Schema.NormalHour do
  @moduledoc """
  The schema for a location's normal hours
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
  schema "normal_hours" do
    field(:day_of_week, :string)

    field(:active, :boolean)
    field(:closed, :boolean)
    field(:deleted_at, :utc_datetime)

    belongs_to(:location, Data.Schema.Location)

    embeds_many :times, Times, on_replace: :delete do
      field(:open_at, :string)
      field(:close_at, :string)
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
    |> cast(params, [:open_at, :close_at])
  end
end
