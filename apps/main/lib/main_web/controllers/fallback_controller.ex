defmodule MainWeb.FallbackController do
  use MainWeb, :controller

  alias MainWeb.ErrorView

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "404.html")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_flash(:error, "You are unauthorized to view this page. It could be due to inactivity. Please login to continue.")
    |> redirect(to: "/")
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:bad_request)
    |> render(ErrorView, :"400", message: "Internal server error")
  end
end
