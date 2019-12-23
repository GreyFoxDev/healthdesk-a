defmodule Data.Schema.Location do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  location_name
  phone_number
  team_id
  |a

  @optional_fields ~w|
  api_key
  web_greeting
  web_handle
  web_chat
  timezone
  address_1
  address_2
  city
  state
  postal_code
  slack_integration
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
    field(:timezone, :string)
    field(:api_key, :string)
    field(:web_greeting, :string)
    field(:web_handle, :string)
    field(:web_chat, :boolean)
    field(:slack_integration, :string)

    field(:deleted_at, :utc_datetime)

    belongs_to(:team, Data.Schema.Team)

    has_many(:team_members, Data.Schema.TeamMember)
    has_many(:users, through: [:team_members, :users])
    has_many(:conversations, Data.Schema.Conversation)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> validate_length(:location_name, max: 250)
    |> validate_length(:phone_number, max: 50)
    |> validate_length(:address_1, max: 250)
    |> validate_length(:address_2, max: 250)
    |> validate_length(:city, max: 100)
    |> validate_length(:state, max: 2)
    |> validate_length(:postal_code, max: 20)
    |> generate_api_key()
  end

  defp generate_api_key(changeset) do
    case get_field(changeset, :api_key) do
      nil -> put_change(changeset, :api_key, UUID.uuid4())
      "" -> put_change(changeset, :api_key, UUID.uuid4())
      _ -> changeset
    end
  end
end
