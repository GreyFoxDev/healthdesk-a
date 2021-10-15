defmodule Data.IntentUsage do

  alias Data.Query.IntentUsage, as: Query
  alias Data.Schema.IntentUsage, as: Schema

  def count_intent_by(%{"team_id" => team_id, "to" => to, "from" => from}),
      do: Query.count_by_team_id(team_id, to, from)

  def count_intent_by(%{"location_ids" => location_ids, "to" => to, "from" => from}),
      do: Query.count_by_location_ids(location_ids, to, from)

  def count_intent_by(%{"to" => to, "from" => from}),
      do: Query.count_intent_by(to, from)

  def count_intent_by(%{}),
      do: Query.count_all()

end