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
    |> put_status(:unauthorized)
    |> render(ErrorView, :"401", message: "You are not authorized for this page")
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:bad_request)
    |> render(ErrorView, :"400", message: "Internal server error")
  end
end
