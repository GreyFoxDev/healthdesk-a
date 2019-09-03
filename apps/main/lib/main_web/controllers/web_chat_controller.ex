defmodule MainWeb.WebChatController do
  use MainWeb, :controller

  plug :put_layout, {MainWeb.LayoutView, :web_chat}

  def index(conn, %{"api_key" => api_key} = params) do
    render(conn, "index.html", %{api_key: api_key})
  end
end
