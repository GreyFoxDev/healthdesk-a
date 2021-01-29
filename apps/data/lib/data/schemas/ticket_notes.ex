defmodule Data.Schema.TicketNote do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          user_id: binary(),
          ticket_id: binary(),
          note: String.t()
        }

  @required_fields ~w|
  user_id
  note
  ticket_id
  |a

  @all_fields @required_fields

  schema "ticket_notes" do
    field(:note, :string)
    belongs_to(:user, Data.Schema.User)
    belongs_to(:ticket, Data.Schema.Ticket)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
