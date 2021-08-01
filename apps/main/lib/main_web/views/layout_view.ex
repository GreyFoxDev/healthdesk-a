defmodule MainWeb.LayoutView do
  use MainWeb, :view

  import Phoenix.HTML.Link

  def settings_url(conn, %{ role: "admin"}) do
    team_path(conn, :index)
  end

  def settings_url(conn, %{ role: role} = current_user) when role in ["team-admin", "location-admin"] do
    team_location_path(conn, :index, current_user.team_member.team_id)
  end

  def current_user(conn) do
    MainWeb.Auth.Guardian.Plug.current_resource(conn)
  end

  def teammate_locations(%Data.Schema.User{}=current_user) do

    current_user.team_member.team_member_locations
    |> Stream.map(&(&1.location))
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Enum.to_list()
    |> Kernel.++([current_user.team_member.location])
    |> Enum.dedup_by(&(&1.id))
  end
  def teammate_locations(conn) do

    current_user = current_user(conn)

    current_user.team_member.team_member_locations
    |> Stream.map(&(&1.location))
    |> Stream.filter(&(&1.deleted_at == nil))
    |> Enum.to_list()
    |> Kernel.++([current_user.team_member.location])
    |> Enum.dedup_by(&(&1.id))
  end
  def title(_conn, assigns) do

       case assigns[:tab]  do
      "ticket"    -> "Healthdesk.ai - Tickets"
      "campaign"    -> "Healthdesk.ai - Campaigns"
      "active"    -> "Healthdesk.ai - Active Conversations"
      "assigned"    -> "Healthdesk.ai -  Assigned Conversations"
      "closed"    -> "Healthdesk.ai -  Closed Conversations"
      "login"    -> "Healthdesk.ai -  Login"
      "none"    -> "Healthdesk.ai"
      "knowledge"    -> "Healthdesk.ai -  Knowledge Base"

      _ -> case assigns[:title] do
            nil -> "Healthdesk.ai - Analytics"
            t-> t
           end
    end
  end
end
