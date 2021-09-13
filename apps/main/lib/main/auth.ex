defmodule MainWeb.Auth do
  @moduledoc false

  import Plug.Conn
  alias Data.User
  alias MainWeb.Auth.Guardian

  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> assign(:current_user, user)
    |> put_user_token(user)
  end

  def logout(conn) do
    user = MainWeb.Auth.Guardian.Plug.current_resource(conn)
    Guardian.Plug.sign_out(conn)
    end

  def load_current_user(conn, _) do
    conn
    |> assign(:current_user, Guardian.Plug.current_resource(conn))
    |> put_user_token(Guardian.Plug.current_resource(conn))
  end

  defp put_user_token(conn, user) do
    conn
    |> sign_token(user)
    |> assign_token()
  end

  defp sign_token(conn, user),
    do: {conn, Phoenix.Token.sign(conn, "user socket", user.id)}

  defp assign_token({conn, token}),
    do: assign(conn, :user_token, token)
end
