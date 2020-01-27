defmodule Data.Schema.PricingPlan do
  @moduledoc """
  The schema for a location's pricing plan options
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          has_daily: boolean() | nil,
          daily: String.t() | nil,
          has_weekly: boolean() | nil,
          weekly: String.t() | nil,
          has_monthly: boolean() | nil,
          monthly: String.t() | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  has_daily
  daily
  has_weekly
  weekly
  has_monthly
  monthly
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "pricing_plans" do
    field(:has_daily, :boolean)
    field(:daily, :string)
    field(:has_weekly, :boolean)
    field(:weekly, :string)
    field(:has_monthly, :boolean)
    field(:monthly, :string)

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
