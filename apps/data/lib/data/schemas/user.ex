defmodule Data.Schema.User do
  @moduledoc """
  The schema for a healthdesk user
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          phone_number: String.t(),
          role: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          email: String.t() | nil,
          avatar: String.t() | nil,
          logged_in_at: :utc_datetime | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
    phone_number
  |a

  @optional_fields ~w|
    role
    first_name
    last_name
    email
    avatar
    use_email
    use_sms
    use_do_not_disturb
    start_do_not_disturb
    end_do_not_disturb
    timezone
    country
    logged_in_at
    deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "users" do
    field(:phone_number, :string)
    field(:country, :string, default: "1")
    field(:role, :string, default: "teammate")
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:avatar, :string)
    field(:use_email, :boolean)
    field(:use_sms, :boolean)
    field(:use_do_not_disturb, :boolean)
    field(:start_do_not_disturb, :string)
    field(:end_do_not_disturb, :string)

    field(:timezone, :string)

    field(:deleted_at, :utc_datetime)
    field(:logged_in_at, :utc_datetime)

    has_one(:team_member, Data.Schema.TeamMember)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:phone_number, name: :active_user_phone_number)
  end
end
