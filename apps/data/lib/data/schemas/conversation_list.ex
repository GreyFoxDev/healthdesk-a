defmodule Data.Schema.ConversationList do
  @moduledoc """
  The schema for a location's conversations
  """
  use Data.Schema

  @primary_key false
  schema "conversations_list" do
    field(:id, :binary_id)
    field(:user_id, :binary_id)
    field(:original_number, :string)
    field(:status, :string)
    field(:started_at, :utc_datetime)
    field(:sent_at, :utc_datetime)
    field(:channel_type, :string)
    field(:subject, :string)
    field(:location_name, :string)
    field(:appointment, :boolean)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:step, :integer)
    field(:fallback, :integer, default: 0)
    field(:member, :map, virtual: true, default: %Data.Schema.Member{})
    belongs_to(:location, Data.Schema.Location)
    belongs_to(:team_member, Data.Schema.TeamMember)
  end
end
