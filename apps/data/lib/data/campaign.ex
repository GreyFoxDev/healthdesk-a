defmodule Data.Campaign do
  @moduledoc """
  This is the campaign API for the data layer
  """
  alias Data.Query.Campaign, as: Query

  defdelegate get(campaign_id), to: Query
  defdelegate create(params), to: Query
  defdelegate update(campaign, params), to: Query
  defdelegate active_campaigns(), to: Query
  defdelegate get_by_location_id(location_id), to: Query
  defdelegate get_by_location_ids(location_ids), to: Query
  defdelegate delete(campaign), to: Query
end
