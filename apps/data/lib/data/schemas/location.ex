defmodule Data.Schema.Location do
  @moduledoc """
  The schema for a team's location
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          team_id: binary(),
          location_name: String.t() | nil,
          phone_number: String.t() | nil,
          api_key: String.t() | nil,
          web_greeting: String.t() | nil,
          web_handle: String.t() | nil,
          web_chat: boolean() | nil,
          timezone: String.t() | nil,
          address_1: String.t() | nil,
          address_2: String.t() | nil,
          city: String.t() | nil,
          state: String.t() | nil,
          google_token: String.t() | nil,
          google_refresh_token: String.t() | nil,
          calender_id: String.t() | nil,
          calender_url: String.t() | nil,
          form_url: String.t() | nil,
          postal_code: String.t() | nil,
          default_message: String.t() | nil,
          slack_integration: String.t() | nil,
          messenger_id: String.t() | nil,
          users: List.t() | nil,
          team_members: List.t() | nil,
          conversations: List.t() | nil,
          mindbody_location_id: String.t() | nil,
          deleted_at: :utc_datetime | nil,
          automation_limit: integer() | 3,
          facebook_page_id: String.t() | nil,
          facebook_token: String.t() | nil,
          whatsapp_login: boolean | false,
          whatsapp_token: String.t() | nil
        }

  @required_fields ~w|
  location_name
  phone_number
  team_id
  |a

  @optional_fields ~w|
  google_token
  google_refresh_token
  calender_id
  calender_url
  form_url
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
  default_message
  slack_integration
  messenger_id
  mindbody_location_id
  deleted_at
  automation_limit
  facebook_page_id
  facebook_token
  whatsapp_login
  whatsapp_token
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "locations" do
    field(:location_name, :string)
    field(:phone_number, :string)
    field(:address_1, :string)
    field(:address_2, :string)
    field(:city, :string)
    field(:state, :string)
    field(:google_token, :string)
    field(:google_refresh_token, :string)
    field(:calender_id, :string)
    field(:calender_url, :string)
    field(:form_url, :string)
    field(:postal_code, :string)
    field(:timezone, :string)
    field(:api_key, :string)
    field(:web_greeting, :string)
    field(:web_handle, :string)
    field(:web_chat, :boolean)
    field(:slack_integration, :string)
    field(:messenger_id, :string)
    field(:default_message, :string)
    field(:mindbody_location_id, :string)
    field(:automation_limit, :integer)
    field(:facebook_page_id, :string)
    field(:facebook_token, :string)
    field(:whatsapp_login, :boolean)
    field(:whatsapp_token, :string)

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
    |> validate_length(:default_message, max: 500)
    |> validate_length(:mindbody_location_id, max: 20)
    |> generate_api_key()
  end

  defp generate_api_key(changeset) do
    case get_field(changeset, :api_key) do
      nil -> put_change(changeset, :api_key, UUID.uuid4())
      _ -> changeset
    end
  end
end
