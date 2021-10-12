defmodule Data.Schema.Intent do
  @moduledoc """
  The schema for a intents
  """
  use Data.Schema

  @type t :: %__MODULE__{
          location_id: binary(),
          intent: String.t(),
          message: String.t()
        }

  @required_fields ~w|
  location_id
  intent
  message
  |a

  @all_fields @required_fields

  schema "intents" do
    field(:intent, :string)
    field(:message, :string)
    belongs_to(:location, Data.Schema.Location)
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
