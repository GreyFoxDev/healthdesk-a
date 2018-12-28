defmodule MainWeb.LayoutView do
  use MainWeb, :view

  import Phoenix.HTML.Link

  def settings_url(conn, %{ role: "admin"} = current_user) do
    IO.inspect current_user
    team_path(conn, :index)
  end
  def settings_url(conn, %{ role: "team_member"}) do
    "/admin/teams"
  end


end
