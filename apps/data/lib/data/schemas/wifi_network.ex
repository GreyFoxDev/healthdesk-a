defmodule Data.Schema.WifiNetwork do
  @moduledoc """
  The schema for a location's wifi information
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          network_name: String.t() | nil,
          network_pword: String.t() | nil,
          deleted_at: :utc_datetime | nil
        }

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
