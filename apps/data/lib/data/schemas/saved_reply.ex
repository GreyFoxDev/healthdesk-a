defmodule Data.Schema.SavedReply do
  @moduledoc """
  The schema for a conversation's messages
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          title: String.t(),
          draft: String.t()
        }

  @required_fields ~w|
  location_id
  title
  draft
  |a

  @all_fields @required_fields

  schema "saved_reply" do
    field(:title, :string)
    field(:draft, :string)
    belongs_to(:location, Data.Schema.Location)
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
