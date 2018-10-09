defmodule MainWeb.SessionController do
  use MainWeb, :controller

  alias Data.User, as: Query
  alias MainWeb.Auth

  action_fallback MainWeb.FallbackController

  plug :scrub_params, "session" when action in [:create]

  def new(conn, _params) do
    conn
    |> put_layout(:login)
    |> render("new.html")
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}})
  when is_nil(phone_number) do
    conn
    |> put_layout(:login)
    |> put_flash(:error, "Phone number can't be blank. Please try again.")
    |> render("new.html")
  end

  def create(conn, %{"session" => %{"verification_code" => code, "phone_number" => phone_number}}) do
    with {:ok, user} <- Query.authorize(phone_number),
         "1234" <- code,
         {:role, "admin"} <- {:role, user.role} do

      redirect_to(conn, user, "/admin/teams")
    else
      _ ->
        conn
        |> put_layout(:login)
        |> put_flash(:error, "Invalid credentials. Please try again.")
        |> render("new.html")
    end
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}}) do
    with {:ok, user} <- Query.authorize(phone_number) do
      conn
      |> put_layout(:login)
      |> put_flash(:success, "Please verify the phone number #{user.first_name}!")
      |> render("verify.html")
    else
      _ ->
        conn
        |> put_layout(:login)
        |> put_flash(:error, "Invalid credentials. Please try again.")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout()
    |> redirect(to: "/")
  end

  defp redirect_to(conn, user, page) do
    conn
    |> Auth.login(user)
    |> put_flash(:success, "Welcome back #{user.first_name}!")
    |> redirect(to: page)
  end
end
