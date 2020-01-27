defmodule Data.ConversationDisposition do
  @moduledoc """
  This is the Conversation Disposition API for the data layer
  """
  alias Data.Query.ConversationDisposition, as: Query

  defdelegate create(params), to: Query
end
