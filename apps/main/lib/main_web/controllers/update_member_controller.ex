defmodule MainWeb.UpdateMemberController do
  use MainWeb, :controller

  alias Data.Member

  def update(conn, %{"id" => id, "member" => member}) do
    case Member.update(id, member) do
      {:ok, _member} ->
        render(conn, "ok.json")
      {:error, _changeset} ->
        render(conn, "error.json")
    end
  end

  def update(conn, %{"member" => _member}) do
    conn
    |> put_status(422)
    |> render("error.json")
  end
end
