defmodule Data.TicketNote do
  @moduledoc """
  This is the ticket API for the data layer
  """
  alias Data.Query.TicketNote, as: Query
  alias Data.Schema.TicketNote

  defdelegate get(id), to: Query
  defdelegate create(params), to: Query

  def get_changeset(),
    do: TicketNote.changeset(%TicketNote{})
end
