defmodule MainWeb.Live.HeaderView do
  use Phoenix.LiveView

  def render(assigns), do: MainWeb.HeaderView.render("header.html", assigns)

  def mount(_assigns, session, socket) do
    socket =
    socket
    |> assign(:current_user, session["current_user"])
    |> assign(:time, parseTime(session["current_user"].logged_in_at))
    {:ok, socket}
  end

  defp parseTime(time) do
    _time = DateTime.to_iso8601(time)
  end
end