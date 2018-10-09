defmodule MainWeb.PageController do
  use MainWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
