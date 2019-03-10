defmodule MainWeb.Plug.AskWit do
  @moduledoc """
  This Plug is used in the pipeline to ask Wit.AI for an intent.
  """

  require Logger

  import Plug.Conn

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  @doc """
  Only once the member has opted in will the question be sent to Wit
  """
  def call(%{assigns: %{opt_in: true, status: "open", message: message}} = conn, _opts),
    do: assign(conn, :intent, ask_wit_ai(message))

  def call(conn, _opts), do: conn

  defp ask_wit_ai(question) do
    with {:ok, _pid} <- WitClient.MessageSupervisor.ask_question(self(), question) do
      receive do
        {:response, response} ->
          response
        _ ->
          :unknown_intent
      end
    else
      {:error, error} ->
        Logger.error("AskWit Plug Error: #{inspect error}")
        :unknown_intent
    end
  end
end
