defmodule Data.Schema.Member do
  @moduledoc false

  use Data.Schema

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
  end
end
