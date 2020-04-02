defmodule Data.Campaign do
  @moduledoc """
  This is the campaign API for the data layer
  """
  alias Data.Query.Campaign, as: Query

  defdelegate create(params), to: Query
  defdelegate update(campaign, params), to: Query
  defdelegate active_campaigns(), to: Query
end
