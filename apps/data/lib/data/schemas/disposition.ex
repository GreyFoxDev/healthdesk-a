defmodule Data.Schema.Disposition do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  disposition_name
  team_id
  |a

  @optional_fields ~w|
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "dispositions" do
    field(:disposition_name, :string)

    field(:deleted_at, :utc_datetime)

    belongs_to(:team, Data.Schema.Team)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
