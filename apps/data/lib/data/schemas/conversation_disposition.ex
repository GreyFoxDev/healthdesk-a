defmodule Data.Schema.ConversationDisposition do
  @moduledoc """
  The schema for a conversation's dispositions
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          conversation_id: binary(),
          disposition_id: binary(),
          conversation_call_id: binary()
        }

  @required_fields ~w|
  disposition_id
  |a

  @optional_fields ~w|
  conversation_call_id
  conversation_id
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "conversation_dispositions" do
    belongs_to(:conversation, Data.Schema.Conversation)
    belongs_to(:disposition, Data.Schema.Disposition)
    belongs_to(:conversation_call, Data.Schema.ConversationCall)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
