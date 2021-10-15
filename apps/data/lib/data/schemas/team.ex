defmodule Data.Schema.Team do
  @moduledoc false

  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          team_name: String.t() | nil,
          website: String.t() | nil,
          twilio_flow_id: String.t() | nil,
          team_member_count: Integer.t() | nil,
          locations: List.t() | nil,
          team_members: List.t() | nil,
          use_mindbody: :boolean | nil,
          mindbody_site_id: String.t() | nil,
          deleted_at: :utc_datetime | nil,
          bot_id: String.t() | nil,
          twilio_sub_account_id: String.t() | nil,
          phone_number: String.t() | nil
        }

  @required_fields ~w|
    team_name
    website
  |a

  @optional_fields ~w|
    team_member_count
    twilio_flow_id
    use_mindbody
    mindbody_site_id
    deleted_at
    bot_id
    twilio_sub_account_id
    phone_number
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "teams" do
    field(:team_name, :string)
    field(:website, :string)
    field(:team_member_count, :integer)
    field(:twilio_flow_id, :string)
    field(:use_mindbody, :boolean)
    field(:mindbody_site_id, :string)
    field(:deleted_at, :utc_datetime)
    field(:bot_id, :string)
    field(:twilio_sub_account_id, :string)
    field(:phone_number, :string)

    has_many(:locations, Data.Schema.Location)
    has_many(:team_members, Data.Schema.TeamMember)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
