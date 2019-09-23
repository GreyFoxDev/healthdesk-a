defmodule MainWeb.Plug.AllowFrom do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts \\ []) do
    delete_resp_header(conn, "x-frame-options")
  end
end
