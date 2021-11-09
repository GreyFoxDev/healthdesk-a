defmodule Data.IntentUsage do

  alias Data.Query.IntentUsage, as: Query

  def count_intent_by(%{"team_id" => team_id, "to" => to, "from" => from}),
      do: Query.count_by_team_id(team_id, to, from)

  def count_intent_by(%{"location_ids" => location_ids, "to" => to, "from" => from}),
      do: Query.count_by_location_ids(location_ids, to, from)

  def count_intent_by(%{"to" => to, "from" => from}),
      do: Query.count_intent_by(to, from)

  def count_intent_by(%{}),
      do: Query.count_all()

  def get_intent_count_after_call_disposition(disposition,to ,from ,loc_ids \\ [])do
    Query.get_intent_after_call(disposition,to ,from ,loc_ids)
#    calls = Data.Query.ConversationCall.get_call_time_list(disposition, to, from, loc_ids)
#    {l, count}= Enum.reduce(calls, {msgs, 0}, fn {call_time, id}, acc ->
#      {msgs, count} = acc
#      c = Enum.filter(msgs, fn {message_time, m_id} -> m_id == id && Timex.between?(message_time, call_time, Timex.shift(call_time, hours: 24)) end)
#          |> Enum.count()
#      {msgs, count = count + c}
#    end)
#
#    count
  end

  def get_leads_count_after_call_disposition(disposition,to ,from ,loc_ids \\ [])do
    Query.get_new_leads(disposition,to ,from ,loc_ids)
  end
end