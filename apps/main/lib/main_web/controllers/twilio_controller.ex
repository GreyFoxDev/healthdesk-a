defmodule MainWeb.TwilioController do
  use MainWeb, :controller

  require Logger

  alias Session.Handler.Supervisor, as: Session

  plug MainWeb.Plug.OptIn

  def create(conn, params) do
    params
    |> build_request()
    |> Session.start_or_update_session()

    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml")
  end

  defp build_request(params) do
    %{
      provider: :twilio,
      from: params["From"],
      to: params["To"],
      body: params["Body"]
    }
  end
end
