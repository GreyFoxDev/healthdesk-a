defmodule Data.Schema.Location do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  location_name
  phone_number
  team_id
  |a

  @optional_fields ~w|
  address_1
  address_2
  city
  state
  postal_code
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "locations" do
    field(:location_name, :string)
    field(:phone_number, :string)
    field(:address_1, :string)
    field(:address_2, :string)
    field(:city, :string)
    field(:state, :string)
    field(:postal_code, :string)

    field(:deleted_at, :utc_datetime)

    belongs_to :team, Data.Schema.Team

    # has_many(:team_members)
    # has_many(:users, through: [:team_members, :users])

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
