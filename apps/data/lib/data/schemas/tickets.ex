defmodule Data.Schema.Ticket do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
               id: binary(),
               user_id: binary(),
               team_member_id: binary() | nil,
               description: String.t(),
               status: String.t(),
               priority: String.t(),
        }

  @required_fields ~w|
  user_id
  description
  |a

  @optional_fields ~w|
  team_member_id
  status
  priority
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "tickets" do
    field(:description, :string)
    field(:status, :string)
    field(:priority, :string)
    belongs_to(:user, Data.Schema.User)
    belongs_to(:team_member_id, Data.Schema.TeamMember)
    has_many(:notes, Data.Schema.TicketNotes)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end


end
