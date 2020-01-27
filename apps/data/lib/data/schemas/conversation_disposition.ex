defmodule Data.Schema.ConversationDisposition do
  @moduledoc """
  The schema for a conversation's dispositions
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          conversation_id: binary(),
          disposition_id: binary()
        }

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
