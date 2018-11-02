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
    params = convert_date(params)
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  defp convert_date(%{"holiday_date" => ""} = params), do: params

  defp convert_date(%{"holiday_date" => << _y :: binary-size(4), "-", _m :: binary-size(2), "-", _d :: binary-size(2) >> = date} = params) do
    Map.merge(params, %{"holiday_date" => "#{date} 00:00:00Z"})
  end

  defp convert_date(params), do: params
end
