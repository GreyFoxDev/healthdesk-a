defmodule Data.MemberChannel do
  @moduledoc """
  This is the Member Channel API for the data layer
  """
  alias Data.Query.MemberChannel, as: Query

  defdelegate create(params), to: Query
  defdelegate get_by_channel_id(channel_id), to: Query
end
