defmodule MainWeb.Plug.CloseConversation do
  @moduledoc """
  Module for the close conversation plug
  """


  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.{Member, Location}
  alias MainWeb.Notify

  @new_leads [
    "salesQuestion",
    "getTour",
    "getTrialPass",
    "getGuestPass",
    "getMonthPass",
    "getDayPass",
    "getWeekPass",
  ]

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

  def call(%{assigns: %{convo: id, location: location, intent: {"unsubscribe", _}}} = conn, _opts) do
    datetime = DateTime.utc_now()
    {:ok, struct} = CM.create(%{
      "conversation_id" => id,
      "phone_number" => location,
      "message" => "unsubscribed",
      "sent_at" => DateTime.add(datetime, 1)})

    convo = C.get(id)
    Member.update(convo.member.id, %{consent: false})
    close_conversation(id, location, "SMS Unsubscribe")

    Main.LiveUpdates.notify_live_view({convo.id, struct})
    :ok =
      Notify.send_to_admin(
        convo.id,
        "unsubscribed",
        location,
        "location-admin"
      )
    conn
  end

  def call(%{assigns: %{convo: id, location: location, intent: {"subscribe", _}}} = conn, _opts) do
    datetime = DateTime.utc_now()
    _ = CM.create(%{
      "conversation_id" => id,
      "phone_number" => location,
      "message" => "subscribed",
      "sent_at" => DateTime.add(datetime, 1)})

    convo = C.get(id)
    Member.update(convo.member.id, %{consent: true})
    close_conversation(id, location, "Automated")
    conn
  end

  @doc """
  If the conversation is in a pending state, or the member has not opted in,
  then no need to do anything. Just return the connection.
  """

  def call(%{assigns: %{convo: id, location: location, status: "pending"}} = conn, _opts) do
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
    C.pending(id)
    conn
  end

  def call(%{assigns: %{convo: id, intent: :unknown_intent}} = conn, _opts) do
    C.pending(id)
    conn
  end

  @doc """
  If the question has been answered then close the conversation
  """
  def call(%{assigns: %{convo: id, location: location} = _assigns} = conn, _opts) do
    loc = Location.get_by_phone(location)
    datetime = DateTime.utc_now()
    intent = elem(conn.assigns[:intent], 0)
    {:ok, saved_message} = CM.create(%{
          "conversation_id" => id,
          "phone_number" => location,
          "message" => conn.assigns[:response],
          "sent_at" => DateTime.add(datetime, 1)})

    if conn.assigns[:response] != loc.default_message  do

      Data.Query.IntentUsage.create(
        %{
          "message_id" => saved_message.id,
          "intent" => intent
        }
      )
    end

    convo = C.get(id)
    location = Data.Location.get(convo.location_id)
    dispositions = Data.Disposition.get_by_team_id(%{role: "system"}, location.team_id)

    if conn.assigns[:response] != "No sweat!" do
      disposition =
      if intent in @new_leads do
        Enum.find(dispositions, &(&1.disposition_name == "New Leads"))
        else
          Enum.find(dispositions, &(&1.disposition_name == "Automated"))
      end

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
#test
    C.close(id)

    _ = ConCache.delete(:session_cache, id)

    conn
  end

  def call(conn, _opts) do
    conn
  end
  defp close_conversation(convo_id, location_id, disposition) do
    location = Location.get_by_phone(location_id)
    disposition =
      %{role: "system"}
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Enum.find(&(&1.disposition_name == disposition))
    if disposition do
      Data.ConversationDisposition.create(%{"conversation_id" => convo_id, "disposition_id" => disposition.id})

      _ =  %{
             "conversation_id" => convo_id,
             "phone_number" => location.phone_number,
             "message" =>
               "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
             "sent_at" => DateTime.add(DateTime.utc_now(), 3)
           }
           |> CM.create()
           |> IO.inspect(label: " CONVERSATION_MESSAGES =>")
    else
      _ = %{
            "conversation_id" => convo_id,
            "phone_number" => location.phone_number,
            "message" =>
              "CLOSED: Closed by System",
            "sent_at" => DateTime.add(DateTime.utc_now(), 3)
          }
          |> CM.create()
    end

    #C.close(convo_id)|> IO.inspect(label: "inside close conversation")
    C.update(%{"id" => convo_id, "status" => "closed","appointment" => false, "team_member_id" => nil})
    ConCache.put(:session_cache, convo_id, 0)
    Main.LiveUpdates.notify_live_view( {location.id, :updated_open})
  end

end
