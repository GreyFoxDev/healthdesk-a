defmodule MainWeb.PageController do
  use MainWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout(:default)
    |> render("index.html")
  end
end
