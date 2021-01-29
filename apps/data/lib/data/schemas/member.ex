defmodule Data.Schema.Member do
  @moduledoc """
  The schema for a team's member

  TODO:
  * Remove consent field
  * Add messenger_id field

  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          team_id: binary(),
          phone_number: String.t(),
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          email: String.t() | nil,
          status: String.t() | nil,
          consent: boolean() | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  phone_number
  team_id
  |a

  @optional_fields ~w|
  first_name
  last_name
  email
  status
  consent
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "members" do
    field(:phone_number, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:status, :string)
    field(:consent, :boolean)

    field(:deleted_at, :utc_datetime)

    belongs_to(:team, Data.Schema.Team)
    has_many(:member_channels, Data.Schema.MemberChannel)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:phone_number, name: :members_phone_number_team_id_index)
    |> unique_constraint(:team_id, name: :members_phone_number_team_id_index)
  end
end
