defmodule Data.Schema.MemberChannel do
  @moduledoc """
  The schema for a member's web channels. Web channels are transient this data logs
  which web channels a member has used.
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          channel_id: String.t(),
          member_id: binary()
        }

  @required_fields ~w|
  channel_id
  member_id
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
