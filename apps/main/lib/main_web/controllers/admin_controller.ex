defmodule MainWeb.AdminController do
  use MainWeb.SecuredContoller

  def index(conn, _params),
    do: render(conn, "index.html")

end
