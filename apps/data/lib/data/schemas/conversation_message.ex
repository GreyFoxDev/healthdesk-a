defmodule Data.Schema.ConversationMessage do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  conversation_id
  phone_number
  message
  sent_at
  |a

  @all_fields @required_fields

  schema "conversation_messages" do
    field(:phone_number, :string)
    field(:message, :text)
    field(:sent_at, :utc_datetime)

    belongs_to(:conversation, Data.Schema.Conversation)
    field(:user, :map, virtual: true)
    field(:member, :map, virtual: true)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
