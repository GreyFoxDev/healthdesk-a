defmodule MainWeb.Plug.CacheQuestion do
  @moduledoc """
  This plug caches questions if the member hasn't opted in. Once the member opts in
  then the question is retrieved from the cache and the process continues.
  """

  import Plug.Conn

  @spec init(list()) :: list()
  def init(opts), do: opts

  @doc """
  Checks if there is a question in the cache or caches a question, If the member
  has already opted in then the conn is returned. If the user has not there are
  a couple options.

  1. It's the question so cache it.
  2. They opted in so retrieve the cached question
  3. They are not opting in so delete any cache they have stored
  """
  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t() | no_return()
  def call(conn, _opts), do: conn

  def call(%{assigns: %{ member: member, message: message}} = conn, _opts) do
    downcased = String.downcase(message)
    cond do
      downcased in ["no", "stop"] ->
        ConCache.delete(:session_cache, member)
        conn
      downcased in ["yes", "start"] ->
        assign(conn, :message, ConCache.get(:session_cache, member))
      true ->
        conn
    end
  end

  def call(%{assigns: %{member: member, message: message}} = conn, _opts)
  when is_binary(member) do

    downcased = String.downcase(message)
    cond do
      downcased in ["no", "stop"] ->
        ConCache.delete(:session_cache, member)
        conn
      downcased in ["yes", "start"] ->
        assign(conn, :message, ConCache.get(:session_cache, member))
      true ->
        ConCache.put(:session_cache, member, message)
        conn
    end
  end

end
