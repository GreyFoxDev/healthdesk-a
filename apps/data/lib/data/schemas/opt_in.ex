defmodule Data.Schema.OptIn do
  @moduledoc false

  use Data.Schema

  @required_fields ~w|
  phone_number
  status
  |a

  schema "opt_ins" do
    field(:phone_number, :string)
    field(:status, :string)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
