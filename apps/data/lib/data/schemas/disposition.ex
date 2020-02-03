defmodule Data.Schema.Disposition do
  @moduledoc """
  The schema for a team's dispositions
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          team_id: binary(),
          disposition_name: String.t(),
          is_system: boolean() | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  disposition_name
  team_id
  |a

  @optional_fields ~w|
  is_system
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "dispositions" do
    field(:disposition_name, :string)
    field(:is_system, :boolean)

    field(:deleted_at, :utc_datetime)

    belongs_to(:team, Data.Schema.Team)

    has_many(:conversation_dispositions, Data.Schema.ConversationDisposition)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
