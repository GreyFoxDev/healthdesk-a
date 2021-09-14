defmodule Data.Schema.ConversationMessage do
  @moduledoc """
  The schema for a conversation's messages
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          conversation_id: binary(),
          phone_number: String.t(),
          message: String.t(),
          read: :boolean | false,
          sent_at: :utc_datetime_usec | nil
        }

  @required_fields ~w|
  conversation_id
  phone_number
  message
  sent_at
  read
  |a

  @all_fields @required_fields

  schema "conversation_messages" do
    field(:phone_number, :string)
    field(:message, :string)
    field(:sent_at, :utc_datetime_usec)
    field(:read, :boolean, default: false)

    belongs_to(:conversation, Data.Schema.Conversation)
    field(:user, :map, virtual: true)
    field(:member, :map, virtual: true)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
