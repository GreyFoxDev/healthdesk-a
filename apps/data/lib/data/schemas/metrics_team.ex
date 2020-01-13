defmodule Data.Schema.MetricsTeam do
  @moduledoc false

  use Data.Schema

  @primary_key false
  schema "metrics_teams" do
    field(:teammates, :integer)
    field(:location_admins, :integer)
    field(:locations, :integer)
    field(:members, :integer)
    field(:inbound_messages, :integer)
    field(:total_sessions, :integer)
    field(:average_messages_per_member, :float)
    field(:average_sessions_per_member, :float)
    field(:total_sms_sessions, :integer)
    field(:total_web_sessions, :integer)
    field(:total_facebook_sessions, :integer)
    field(:bounce_rate, :float)

    belongs_to(:team, Data.Schema.Team)
  end
end
