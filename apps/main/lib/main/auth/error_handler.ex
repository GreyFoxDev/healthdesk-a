defmodule MainWeb.Auth.AuthErrorHandler do
  @moduledoc false

  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    body = """
    Unauthorized to view page.
    """
    send_resp(conn, 401, body)
  end
end
