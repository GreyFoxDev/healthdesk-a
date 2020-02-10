defmodule Data.ClassSchedule do
  @moduledoc """
  This is the Child Care Hours API for the data layer
  """
  alias Data.Query.ClassSchedule, as: Query

  defdelegate create(params), to: Query
  defdelegate delete(params), to: Query
  defdelegate get_by_location_id(location_id), to: Query
  defdelegate all(location_id), to: Query, as: :get_by_location_id
end
