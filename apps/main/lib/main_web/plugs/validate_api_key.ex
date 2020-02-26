defmodule MainWeb.Plug.ValidateApiKey do
  import Plug.Conn

  alias Data.Location
  alias Data.Schema.Location, as: Schema

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(%{params: %{"api_key" => api_key}} = conn, _opts) do
    with %Schema{} = location <- Location.get_by_api_key(api_key) do
      assign(conn, :location,  location)
    else
      nil ->
        conn
        |> put_status(404)
        |> send_resp(404, "Page not found")
        |> halt()
    end
  end

  def call(conn, _opts) do
    halt(conn)
  end
end
