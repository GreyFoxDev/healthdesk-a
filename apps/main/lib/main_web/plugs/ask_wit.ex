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
  def call(%{assigns: %{convo: id,  status: "open", message: message}} = conn, _opts,location) do


    pending_message_count = (ConCache.get(:session_cache, id) || 0)
    if pending_message_count == 0 && conn.assigns[:team_member_id] == nil  do
      assign(conn, :intent, ask_wit_ai(message, location))
    else
      assign(conn, :intent, nil)
    end




  end

  def call(conn, _opts), do: conn

  defp ask_wit_ai(question, location) do
    bot_id=Team.get_bot_id_by_location_id(location.id)
    with {:ok, _pid} <- WitClient.MessageSupervisor.ask_question(self(), question, bot_id) do
      receive do
        {:response, response} ->
          IO.inspect("###################")
          IO.inspect(response)
          IO.inspect("###################")

          response
        _ ->
          {:unknown_intent, []}
      end
    else
      {:error, _error} ->
        {:unknown_intent, []}
    end
  end
end
