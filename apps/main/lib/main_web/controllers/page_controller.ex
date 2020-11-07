defmodule MainWeb.PageController do
  use MainWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout(:default)
    |> assign(:tab,"none")
    |> render("index.html")
  end

  def secret(conn, _params) do
    conn
    |> put_layout(:default)
    |> render("secret.html")
  end
end
