defmodule MainWeb.HealthCheckController do
  use MainWeb, :controller

  def status(conn, _) do
    json(conn, %{success: :ok})
  end
end
