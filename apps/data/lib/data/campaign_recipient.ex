defmodule Data.CampaignRecipient do
  @moduledoc """
  This is the campaign API for the data layer
  """
  alias Data.Query.CampaignRecipient, as: Query

  defdelegate create(params), to: Query
  defdelegate update(recipient, params), to: Query
  defdelegate get_by_campaign_id(campaign_id), to: Query
end
