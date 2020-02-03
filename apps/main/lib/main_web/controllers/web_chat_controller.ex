defmodule MainWeb.WebChatController do
  use MainWeb, :controller

  plug :put_layout, {MainWeb.LayoutView, :web_chat}
  plug MainWeb.Plug.AllowFrom

  def index(conn, %{"api_key" => api_key}) do
    ip =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    render(conn, "index.html", %{api_key: api_key, ip: ip})
  end
end
