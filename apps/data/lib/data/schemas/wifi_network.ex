defmodule Data.Schema.WifiNetwork do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  network_name
  network_pword
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "wifi_networks" do
    field(:network_name, :string)
    field(:network_pword, :string)

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
