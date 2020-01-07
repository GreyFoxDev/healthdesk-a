defmodule Data.Schema.ConversationDisposition do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  conversation_id
  disposition_id
  |a

  schema "conversation_dispositions" do
    belongs_to(:conversation, Data.Schema.Conversation)
    belongs_to(:disposition, Data.Schema.Disposition)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
