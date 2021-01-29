defmodule Data.Schema.Appointment do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          conversation_id: binary() | nil,
          name: String.t(),
          type: String.t(),
          email: String.t(),
          phone: String.t(),
          date: String.t(),
          time: String.t(),
          member_id: binary(),
          link: String.t(),
          confirmed: :boolean | false
        }

  @required_fields ~w|
  |a

  @optional_fields ~w|
  name
  email
  type
  phone
  conversation_id
  date
  time
  member_id
  link
  confirmed
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "appointments" do
    field(:name, :string)
    field(:type, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:date, :string)
    field(:time, :string)
    field(:link, :string)
    field(:confirmed, :boolean, default: false)

    belongs_to(:conversation, Data.Schema.Conversation)
    belongs_to(:member, Data.Schema.Member)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
