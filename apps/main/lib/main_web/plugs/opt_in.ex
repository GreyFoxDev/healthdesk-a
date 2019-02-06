defmodule MainWeb.Plug.OptIn do
  @moduledoc """
  This plug is responsible for determining if the member has opted in. If the
  user has not opted in then a response is sent back asking for the member to
  'opt in'. If the user replies with a 'no' then opt out response is sent.
  """

  import Plug.Conn

  alias Data.Commands.OptIn, as: O

  @opt_in_message """
  To receive a response to your inquiry, you must opt-in. Reply YES for recurring automated SMS/MMS marketing messages powered by Healthdesk. No purchase required. Message and data rates may apply. Terms: https://healthdesk.ai/terms
  """

  @opt_out_message """
  You have successfully opted-out. You will not receive any more messages from this number. Reply START to resubscribe at any time.
  """

  @spec init(list()) :: list()
  def init(opts), do: opts

  @doc """
  Checks if a number has opted in and then replies accordingly.
  """
  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  def call(%{assigns: %{member: member, message: message}} = conn, _opts) when is_binary(member) do
    with {:ok, %{status: "yes"}} <- O.get_by_phone(member) do
      assign(conn, :opt_in, true)
    else
      {:ok, _} ->
        cond do
        String.downcase(message) in ["yes", "start"] ->
          {:ok, _optin} = O.enable_opt_in(member)

          assign(conn, :opt_in, true)
        String.downcase(message) == "no" ->
          {:ok, _optin} = O.disable_opt_in(member)

          conn
          |> assign(:opt_in, false)
          |> assign(:response, @opt_out_message)
        true ->
          conn
          |> assign(:opt_in, false)
          |> assign(:response, @opt_in_message)
      end
    end
  end

  def call(conn, _opts),do: assign(conn, :opt_in, false)

end
