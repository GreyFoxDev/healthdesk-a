defmodule MainWeb.Plug.CloseConversation do
  @moduledoc """
  Module for the close conversation plug
  """


  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.{Member, Location}
  alias MainWeb.Notify

  @spec init(list()) :: list()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: Plug.Conn.t()
  def call(conn, opts)

  @doc """
  If the conversation is in a pending state or closed and conversation is being hit by outbound_api,
  we will keep conversation closed.
  """
  def call(%{assigns: %{convo: id, barcode: barcode, status: "closed"}} = conn, _opts) when (barcode != nil) do
    C.close(id)
    conn
  end

  @doc """
  If the conversation is in a pending state, or the member has not opted in,
  then no need to do anything. Just return the connection.
  """
  def call(%{assigns: %{convo: id, location: location, status: "pending"}} = conn, _opts) do
    IO.inspect("########we are here###########")


    _convo = C.get(id)
    pending_message_count = (ConCache.get(:session_cache, id) || 0)

    if pending_message_count <= 1 do
     _ = CM.create(%{
            "conversation_id" => id,
            "phone_number" => location,
            "message" => conn.assigns[:response],
            "sent_at" => DateTime.utc_now()})
    end

    C.pending(id)
    conn
  end

  @doc """
  If the intent isn't found then set the conversation status to pending while
  an admin addresses the member.
  """
  def call(%{assigns: %{convo: _id, intent: nil}} = conn, _opts), do: conn
  def call(%{assigns: %{convo: id, location: location, appointment: true} = _assigns} = conn, _opts) do
    IO.inspect("########we are heres###########")
    IO.inspect(conn.assigns[:response])
    IO.inspect("###################")

    datetime = DateTime.utc_now()
    _ = CM.create(%{
      "conversation_id" => id,
      "phone_number" => location,
      "message" => conn.assigns[:response],
      "sent_at" => DateTime.add(datetime, 1)})

    C.close(id)

    _ = ConCache.delete(:session_cache, id)

    conn
  end

  def call(%{assigns: %{convo: id, intent: {:unknown, []}}} = conn, _opts) do
    IO.inspect("----------------unknown intent---------------")
    C.pending(id)
    conn
  end

  def call(%{assigns: %{convo: id, intent: :unknown_intent}} = conn, _opts) do
    IO.inspect("----------------unknown_intent intent---------------")
    C.pending(id)
    conn
  end

  def call(%{assigns: %{convo: id,location: location, intent: {:subscribe, []}}} = conn, _opts) do
    IO.inspect("----------------subscribe intent---------------")
    datetime = DateTime.utc_now()
    _ = CM.create(%{
      "conversation_id" => id,
      "phone_number" => location,
      "message" => "subscribed",
      "sent_at" => DateTime.add(datetime, 1)})

    convo = C.get(id)
    Member.update(convo.member.id, %{consent: true})
    C.close(id)
    conn
  end
  def call(%{assigns: %{convo: id,location: location, intent: {:unsubscribe, []}}} = conn, _opts) do
    IO.inspect("------unsubscribe intent-----------")
    datetime = DateTime.utc_now()
    {:ok, struct} = CM.create(%{
      "conversation_id" => id,
      "phone_number" => location,
      "message" => "unsubscribed",
      "sent_at" => DateTime.add(datetime, 1)})

    convo = C.get(id)
    Member.update(convo.member.id, %{consent: false})
    C.close(id)

    Main.LiveUpdates.notify_live_view({convo.id, struct})
    :ok =
      Notify.send_to_admin(
        convo.id,
        "unsubscribed",
        location.phone_number,
        "location-admin"
      )
    conn
  end

#  defp close_conversation(convo_id, location_id) do
#    location = Location.get_by_phone(location_id)
#    disposition =
#      %{role: "system"}
#      |> Data.Disposition.get_by_team_id(location.team_<id)
#      |> Enum.find(&(&1.disposition_name == "Automated"))
#
#    if disposition do
#      Data.ConversationDisposition.create(%{"conversation_id" => convo_id, "disposition_id" => disposition.id})
#
#      _ =  %{
#             "conversation_id" => convo_id,
#             "phone_number" => location.phone_number,
#             "message" =>
#               "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
#             "sent_at" => DateTime.add(DateTime.utc_now(), 3)
#           }
#           |> CM.create()
#    else
#      _ = %{
#            "conversation_id" => convo_id,
#            "phone_number" => location.phone_number,
#            "message" =>
#              "CLOSED: Closed by System",
#            "sent_at" => DateTime.add(DateTime.utc_now(), 3)
#          }
#          |> CM.create()
#    end
#
#    C.close(convo_id)
#  end

  @doc """
  If the question has been answered then close the conversation
  """
  def call(%{assigns: %{convo: id, location: location} = _assigns} = conn, _opts) do
    IO.inspect("########we are here2###########")
    IO.inspect(conn.assigns[:response])
    IO.inspect("###################")

    datetime = DateTime.utc_now()
    _ = CM.create(%{
          "conversation_id" => id,
          "phone_number" => location,
          "message" => conn.assigns[:response],
          "sent_at" => DateTime.add(datetime, 1)})

    convo = C.get(id)
    location = Data.Location.get(convo.location_id)
    dispositions = Data.Disposition.get_by_team_id(%{role: "system"}, location.team_id)

    if conn.assigns[:response] != "No sweat!" do
      disposition = Enum.find(dispositions, &(&1.disposition_name == "Automated"))

      Data.ConversationDisposition.create(%{"conversation_id" => id, "disposition_id" => disposition.id})

      _ =  %{"conversation_id" => id,
        "phone_number" => location.phone_number,
        "message" => "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.add(datetime, 3)}
      |> CM.create()
    else
      _ =  %{"conversation_id" => id,
        "phone_number" => location.phone_number,
        "message" => "CLOSED: Closed by System",
        "sent_at" => DateTime.add(datetime, 3)}
      |> CM.create()
    end

    C.close(id)

    _ = ConCache.delete(:session_cache, id)

    conn
  end

  def call(conn, _opts) do
    IO.inspect("=======================default Clause=====================")
    IO.inspect("default Clause")
    IO.inspect("=======================default Clause=====================")
    conn
  end

end
