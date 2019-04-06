defmodule MainWeb.Helper.SidebarNav do

  def get_nav(current_user, location_id \\ nil)
  def get_nav(%{role: "admin"}, _location_id) do

  end

  def get_nav(%{role: "teammate"}, _location_id) do

  end

end
