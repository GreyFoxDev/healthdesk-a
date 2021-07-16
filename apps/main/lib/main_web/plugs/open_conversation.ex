defmodule MainWeb.Plug.OpenConversation do
  @moduledoc """
  This plug finds any previous conversation or starts a new one.
  The conversation is added to the assigns.
  """

  require Logger

  import Plug.Conn

  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.Schema.Conversation, as: Schema

  @spec init(list()) :: list()
  def init(opts), do: opts

  @doc """
  Find or create a conversation for the member
  """
  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(%{assigns: %{member: member, location: location}} = conn, _opts)
  when is_binary(member) and is_binary(location) do
    with {:ok, %Schema{} = convo} <- C.find_or_start_conversation({member, location}) do

      _ = CM.create(%{
            "conversation_id" => convo.id,
            "phone_number" => member,
            "message" => conn.assigns[:message],
            "sent_at" => DateTime.utc_now()})

      conn
      |> assign(:convo, convo.id)
      |> assign(:status, convo.status)
      |> assign(:team_member_id, convo.team_member_id)
    else
      {:error, _message} ->
        Logger.error("MEMBER: #{member}\nLOCATION: #{location}\n - Error finding or starting a conversation")
        assign(conn, :error, true)
    end
  end

  def call(conn, _opts), do: conn
end
