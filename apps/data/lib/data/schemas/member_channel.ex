defmodule Data.Schema.MemberChannel do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  member_id
  channel_id
  |a

  @all_fields @required_fields

  schema "member_channels" do
    field(:channel_id, :string)

    belongs_to(:member, Data.Schema.Member)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
