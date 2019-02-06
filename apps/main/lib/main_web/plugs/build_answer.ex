defmodule MainWeb.Plug.BuildAnswer do
  @moduledoc """

  """

  require Logger

  import Plug.Conn

  @storage Application.get_env(:session, :storage, Data.Intent)

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  def call(%{assigns: %{opt_in: true, intent: intent, location: location}} = conn, _opts),
    do: assign(conn, :response, @storage.get_message(intent, location))

  def call(conn, _opts), do: conn
end
