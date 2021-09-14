defmodule Data.Schema.Notification do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          user_id: binary(),
          conversation_id: binary() | nil,
          ticket_id: binary() | nil,
          from: binary() | nil,
          text: String.t(),
          read: :boolean | false
        }

  @required_fields ~w|
  |a

  @optional_fields ~w|
  text
  user_id
  from
  conversation_id
  ticket_id
  read
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "notifications" do
    field(:text, :string)
    field(:read, :boolean, default: false)

    belongs_to(:user, Data.Schema.User)
    belongs_to(:sender, Data.Schema.User, foreign_key: :from)
    belongs_to(:conversation, Data.Schema.Conversation)
    belongs_to(:ticket, Data.Schema.Ticket)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
