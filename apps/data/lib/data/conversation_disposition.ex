defmodule Data.ConversationDisposition do
  @moduledoc """
  This is the Conversation Disposition API for the data layer
  """
  alias Data.Query.ConversationDisposition, as: Query

  defdelegate create(params), to: Query
  defdelegate count_channel_type_by_team_id(channel_type, team_id), to: Query
  defdelegate count_channel_type_by_location_id(channel_type, location_id), to: Query
  defdelegate count_all_by_channel_type(channel_type), to: Query

end
