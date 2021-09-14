defmodule Data.Ticket do
  @moduledoc """
  This is the ticket API for the data layer
  """
  alias Data.Query.Ticket, as: Query
  alias Data.Schema.Ticket

  defdelegate get(ticket_id), to: Query
  defdelegate create(params), to: Query
  defdelegate update(ticket, params), to: Query
  defdelegate active_tickets(), to: Query
  defdelegate all_tickets(), to: Query
  defdelegate get_by_team_id(team_id), to: Query
  defdelegate get_by_team_and_location_id(team_id, location_id), to: Query
  defdelegate get_by_team_member_id(team_member_id), to: Query
  defdelegate get_by_team_member_and_location_id(team_member_id, location_id), to: Query
  defdelegate get_by_location_id(location_id), to: Query
  defdelegate get_by_location_ids(location_id), to: Query
  defdelegate get_by_admin_location(team_member_id), to: Query
  defdelegate delete(ticket), to: Query
  defdelegate filter(params), to: Query

  def count_by(params),
    do: Query.count_by(params)

  def count_by(params),
    do: Query.count_by(params)

  def get_changeset(),
    do: Ticket.changeset(%Ticket{})
end
