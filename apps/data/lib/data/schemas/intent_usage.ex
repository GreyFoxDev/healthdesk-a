defmodule Data.Schema.IntentUsage do

  use Data.Schema
  @type t :: %__MODULE__{
               id: binary(),
               message_id: binary(),
               intent: String.t(),
             }

  @required_fields ~w|
  intent
  |a

  @optional_fields ~w|
message_id
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "intent_usage" do
    field(:intent, :string)
    belongs_to(:message, Data.Schema.ConversationMessage)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end