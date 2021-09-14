defmodule Data.Schema.Automation do
  @moduledoc """
  The schema for a location's automations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          question: Text.t(),
          answer: Text.t() | nil,
          location_id: binary()
        }

  @required_fields ~w|
  location_id
  question
  answer
  |a

  @optional_fields ~w|
|a

  @all_fields @required_fields ++ @optional_fields

  schema "automations" do
    field(:question, :string)
    field(:answer, :string)

    belongs_to(:location, Data.Schema.Location)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
