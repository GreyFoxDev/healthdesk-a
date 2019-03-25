defmodule MainWeb.LayoutView do
  use MainWeb, :view

  import Phoenix.HTML.Link

  def settings_url(conn, %{ role: "admin"} = current_user) do
    team_path(conn, :index)
  end

  def settings_url(conn, %{ role: role} = current_user) when role in ["team-admin", "location-admin"] do
    team_location_path(conn, :index, current_user.team_member.team_id)
  end

end
