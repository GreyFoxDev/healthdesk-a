defmodule MainWeb.Plug.OptIn do
  @moduledoc """
  This plug is responsible for determining if the member has opted in. If the
  user has not opted in then a response is sent back asking for the member to
  'opt in'. If the user replies with a 'no' then opt out response is sent.
  """

  import Plug.Conn

  alias Data.Commands.{Member, Location}

  @opt_in_message """
  Hello! We've received your message, however, since this is your first time texting us, you must opt-in before we can respond. You'll only have to do this once. Reply 'yes' to receive automated SMS/MMS messages. No purchase required. Message and data rates may apply. Terms: https://healthdesk.ai/terms
  """

  @opt_in_message_10 """
  Hello! Please opt-in to receive a response to your inquiry. You'll only need to do this once. Reply 'yes' to receive automated SMS/MMS messages. No purchase required. Msg&data rates may apply. Terms: https://healthdesk.ai/terms
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

  def call(%{assigns: %{member: member, message: message, location: location}} = conn, _opts) when is_binary(member) do
    with {:ok, %{consent: true}} <- Member.get_by_phone(member) do
      assign(conn, :opt_in, true)
    else
      {:ok, _} ->
        message = String.downcase(message) |> String.trim()
        cond do
        message in ["yes", "start"] ->
          {:ok, _optin} = Member.enable_opt_in(member, location)

          conn
          |> assign(:opt_in, true)
          |> assign(:message, message)
        message == "no" ->
          {:ok, _optin} = Member.disable_opt_in(member, location)

          conn
          |> assign(:opt_in, false)
          |> assign(:response, @opt_out_message)
        true ->
          location = Location.get_by_phone(location)
          if location.team.team_name == "10 Fitness" do
            conn
            |> assign(:opt_in, false)
            |> assign(:response, @opt_in_message_10)
          else
            conn
            |> assign(:opt_in, false)
            |> assign(:response, @opt_in_message)
          end

      end
    end
  end

  def call(conn, _opts),do: assign(conn, :opt_in, false)

end
