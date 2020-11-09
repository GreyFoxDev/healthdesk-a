defmodule MainWeb.SessionController do
  use MainWeb, :controller

  alias Data.User, as: Query
  alias MainWeb.Auth
  alias Chatbot.Client.Twilio

  action_fallback MainWeb.FallbackController

  plug :scrub_params, "session" when action in [:create]

  def new(conn, _params) do
    conn
    |> put_layout(:login)
    |> assign(:tab,"login")
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
    with user when not is_nil(user) <- Query.get_by_phone(phone_number),
         :ok <- Twilio.check(phone_number, code) do
      case user.role do
        "admin" ->
          redirect_to(conn, user, "/admin/")
        "team-admin" ->
          redirect_to(conn, user, "/admin/")
        _ ->
          path = live_path(conn, MainWeb.Live.ConversationsView, "active")
          redirect_to(conn, user, path)
      end
    else
      _ ->
        conn
        |> put_layout(:login)
        |> put_flash(:error, "Invalid credentials. Please try again.")
        |> render("new.html")
    end
  end

  def create(conn, %{"session" => %{"phone_number" => phone_number}}) do
    with user when not is_nil(user) <- Query.get_by_phone(phone_number),
         :ok <- Twilio.verify(phone_number) do
      conn
      |> put_layout(:login)
      |> put_flash(:success, "Please verify the phone number #{user.first_name}!")
      |> render("verify.html")
    else
      {:error, :error_sending_verification} ->
        conn
        |> put_layout(:login)
        |> put_flash(:error, "Unable to send verification code. Please try again later.")
        |> render("new.html")
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
