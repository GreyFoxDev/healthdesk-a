defmodule Data.Schema.User do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
    phone_number
  |a

  @optional_fields ~w|
    role
    first_name
    last_name
    email
    deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "users" do
    field(:phone_number, :string)
    field(:role, :string, default: "team_member")
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)

    field(:deleted_at, :utc_datetime)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
