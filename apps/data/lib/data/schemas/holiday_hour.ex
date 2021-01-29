defmodule Data.Schema.HolidayHour do
  @moduledoc """
  The schema for a location's holiday hours

  TODO:
  * Change holiday_date field to date, not UTC date time
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          holiday_name: String.t() | nil,
          closed: boolean() | nil,
          holiday_date: :utc_datetime | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  holiday_name
  holiday_date
  closed
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "holiday_hours" do
    field(:holiday_name, :string)
    field(:holiday_date, :utc_datetime)
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
    params = convert_date(params)

    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def update_changeset(model, params \\ %{}) do
    params = convert_date(params)

    model
    |> cast(params, @all_fields)
    |> cast_embed(:times, with: &times_changeset/2)
    |> validate_required(@required_fields)
  end

  defp convert_date(%{"holiday_date" => date} = params) do
    Map.merge(params, %{"holiday_date" => "#{date} 00:00:00Z"})
  end

  defp convert_date(params), do: params

  defp times_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:open_at, :close_at])
  end
end
