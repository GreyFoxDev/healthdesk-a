defmodule Data.Schema.Conversation do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          team_member_id: binary() | nil,
          original_number: String.t(),
          status: String.t() | nil,
          started_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  original_number
  |a

  @optional_fields ~w|
  status
  started_at
  team_member_id
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "conversations" do
    field(:original_number, :string)
    field(:status, :string)
    field(:started_at, :utc_datetime)

    field(:member, :map, virtual: true, default: %Data.Schema.Member{})

    belongs_to(:location, Data.Schema.Location)
    belongs_to(:team_member, Data.Schema.TeamMember)

    has_many(:conversation_messages, Data.Schema.ConversationMessage)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
