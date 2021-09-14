defmodule Data.Schema.Conversation do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          team_member_id: binary() | nil,
          original_number: String.t(),
          channel_type: String.t() | nil,
          status: String.t() | nil,
          subject: String.t() | nil,
          started_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  original_number
  |a

  @optional_fields ~w|
  status
  started_at
  team_member_id
  channel_type
  fallback
  subject
  appointment
  step
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "conversations" do
    field(:original_number, :string)
    field(:status, :string)
    field(:started_at, :utc_datetime)
    field(:channel_type, :string)
    field(:subject, :string)
    field(:appointment, :boolean)
    field(:step, :integer)
    field(:fallback, :integer, default: 0)

    field(:member, :map, virtual: true, default: %Data.Schema.Member{})

    belongs_to(:location, Data.Schema.Location)
    belongs_to(:team_member, Data.Schema.TeamMember)

    has_many(:conversation_messages, Data.Schema.ConversationMessage)

    timestamps(type: :naive_datetime_usec)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> put_channel_type()
  end

  defp put_channel_type(changeset) do
    changeset
    |> get_field(:channel_type)
    |> case do
      nil ->
        changeset
        |> get_field(:original_number)
        |> set_channel_type(changeset)

      _channel_type ->
        changeset
    end
  end

  defp set_channel_type(nil, changeset), do: changeset

  defp set_channel_type(<<"messenger:", _::binary>>, changeset) do
    put_change(changeset, :channel_type, "FACEBOOK")
  end

  defp set_channel_type(<<"CH", _::binary>>, changeset) do
    put_change(changeset, :channel_type, "WEB")
  end

  defp set_channel_type(<<"+1", _::binary>>, changeset) do
    put_change(changeset, :channel_type, "SMS")
  end

  defp set_channel_type(<<"APP", _::binary>>, changeset) do
    put_change(changeset, :channel_type, "APP")
  end

  defp set_channel_type(email, changeset) do
    regex = ~r{([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)}

    if Regex.match?(regex, email) do
      put_change(changeset, :channel_type, "MAIL")
    else
      put_change(changeset, :channel_type, "SMS")
    end
  end
end
