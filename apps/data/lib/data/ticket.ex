defmodule Data.Ticket do
  @moduledoc """
  This is the ticket API for the data layer
  """
  alias Data.Query.Ticket, as: Query

  defdelegate get(ticket_id), to: Query
  defdelegate create(params), to: Query
  defdelegate update(ticket, params), to: Query
  defdelegate active_tickets(), to: Query
  defdelegate get_by_location_id(location_id), to: Query
  defdelegate delete(ticket), to: Query
  def get_changeset(),
      do: Data.Schema.Ticket.changeset(%Data.Schema.Ticket{})

end
