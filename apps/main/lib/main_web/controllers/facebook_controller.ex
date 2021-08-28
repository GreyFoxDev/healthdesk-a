defmodule MainWeb.FacebookController do
  use MainWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def hook(conn, %{"hub.challenge" => challenge,"location_id" => id, "team_id" => team_id, "provider" => provider}=_params) when provider == "facebook" do
    conn
    |> Plug.Conn.resp(200, challenge)
    |> Plug.Conn.send_resp()
  end
  def hook(conn, _) do
    conn
    |> Plug.Conn.resp(200, "")
    |> Plug.Conn.send_resp()
  end

  def event(conn, %{"entry" => data, "provider" => provider, "team_id" => team_id, "location_id" => location_id}) do
    IO.inspect("=======================params=====================")
    IO.inspect(data)
    IO.inspect("=======================params=====================")
    conn
    |> Plug.Conn.resp(200, "")
    |> Plug.Conn.send_resp()
  end
end
