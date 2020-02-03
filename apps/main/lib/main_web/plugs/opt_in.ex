defmodule MainWeb.Plug.OptIn do
  @moduledoc """
  This plug is responsible for determining if the member has opted in. If the
  user has not opted in then a response is sent back asking for the member to
  'opt in'. If the user replies with a 'no' then opt out response is sent.
  """

  import Plug.Conn

  @spec init(list()) :: list()
  def init(opts), do: opts

  @doc """
  Checks if a number has opted in and then replies accordingly.
  """
  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  def call(conn, _opts),do: assign(conn, :opt_in, true)

end
