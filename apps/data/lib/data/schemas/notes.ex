defmodule Data.Schema.Note do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          user_id: binary(),
          conversation_id: binary() | nil,
          text: String.t()
        }

  @required_fields ~w|
  text
  user_id
  conversation_id

  |a

  @all_fields @required_fields

  schema "notes" do
    field(:text, :string)

    belongs_to(:user, Data.Schema.User)
    belongs_to(:conversation, Data.Schema.Conversation)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
