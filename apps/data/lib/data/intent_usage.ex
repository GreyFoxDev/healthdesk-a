defmodule Data.IntentUsage do

  alias Data.Query.IntentUsage, as: Query
  alias Data.Schema.IntentUsage, as: Schema

  @call_dispositions [
    "Call deflected",
    "Missed Call Texted",
    "Call Transfered",
    "Call Hung Up"
  ]

  def count_intent_by(%{"team_id" => team_id, "to" => to, "from" => from}),
      do: Query.count_by_team_id(team_id, to, from)

  def count_intent_by(%{"location_ids" => location_ids, "to" => to, "from" => from}),
      do: Query.count_by_location_ids(location_ids, to, from)

  def count_intent_by(%{"to" => to, "from" => from}),
      do: Query.count_intent_by(to, from)

  def count_intent_by(%{}),
      do: Query.count_all()

  def get_intent_count_after_call_disposition(disposition,to ,from ,loc_ids \\ []) when disposition in @call_dispositions do
    Query.get_intent_after_call(disposition,to ,from ,loc_ids)
  end

  def get_leads_count_after_call_disposition(disposition,to ,from ,loc_ids \\ []) when disposition in @call_dispositions do
    Query.get_new_leads(disposition,to ,from ,loc_ids)
  end
end