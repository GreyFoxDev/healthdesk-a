defmodule MainWeb.FacebookController do
  use MainWeb, :controller
  plug Ueberauth
  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.Schema.Conversation, as: Schema
  alias Main.Service.Appointment
  alias Data.Team

  alias MainWeb.{Notify}

  alias Data.{Member, TimezoneOffset, TeamMember, Conversations}

  alias Ueberauth.Strategy.Helpers
  alias Data.{Location, Team}

  def hook(conn, %{"hub.challenge" => challenge}=_params) do
    conn
    |> Plug.Conn.resp(200, challenge)
    |> Plug.Conn.send_resp()
  end
  def hook(conn, _) do
    conn
    |> Plug.Conn.resp(200, "")
    |> Plug.Conn.send_resp()
  end

  def event(conn, %{"entry" => [%{"messaging" => [%{"message" => %{"text" =>msg}, "sender" => %{"id" => sid},"recipient" => %{"id" => pid}}|_]}|_]}) do
    IO.inspect("=======================params=====================")
    IO.inspect(sid)
    IO.inspect(pid)
    IO.inspect(msg)
    IO.inspect("=======================params=====================")
    location = Location.get_by_page_id(pid)
    with %Schema{} = convo <- C.get_by_phone("messenger:#{sid}", location.id) do
      update_convo(msg,convo,location)
    else
      nil ->
        with {:ok, %Schema{} = convo} <- C.find_or_start_conversation({"messenger:#{sid}", location.phone_number}) do
          update_convo(msg,convo,location)
        end
    end
    conn
    |> Plug.Conn.resp(200, "")
    |> Plug.Conn.send_resp()
  end
  def update_convo(message,convo,location)do
    _ = CM.create(
      %{
        "conversation_id" => convo.id,
        "phone_number" => convo.original_number,
        "message" => message,
        "sent_at" => DateTime.utc_now()
      })
    if convo.status == "closed" do
      message
      |> ask_wit_ai(convo.id, location)
      |> case do
           {:ok, response} ->
             _ = CM.create(
               %{
                 "conversation_id" => convo.id,
                 "phone_number" => location.phone_number,
                 "message" => response,
                 "sent_at" => DateTime.add(DateTime.utc_now(), 2)
               }
             )
             reply_to_facebook(response,location,String.replace(convo.original_number,"messenger:",""))
             close_conversation(convo.id, location)
           {:unknown, response} ->
             _ = CM.create(
               %{
                 "conversation_id" => convo.id,
                 "phone_number" => location.phone_number,
                 "message" => response,
                 "sent_at" => DateTime.add(DateTime.utc_now(), 2)
               }
             )
             reply_to_facebook(response,location,String.replace(convo.original_number,"messenger:",""))
             C.pending(convo.id)
             Main.LiveUpdates.notify_live_view({location.id, :updated_open})
             :ok =
               Notify.send_to_admin(
                 convo.id,
                 "Message From: #{convo.original_number}\n#{message}",
                 location.phone_number
               )
         end
    end
  end

  defp ask_wit_ai(question, convo_id, location) do
    bot_id = Team.get_bot_id_by_location_id(location.id)
    with {:ok, _pid} <- WitClient.MessageSupervisor.ask_question(self(), question, bot_id) do
      receive do
        {:response, response} ->
          IO.inspect("#########")
          IO.inspect(response)
          IO.inspect("#########")
          message =  Appointment.get_next_reply(convo_id, response, location.phone_number)
          if String.contains?(message,location.default_message) do
            {:unknown, message}
          else
            {:ok, message}
          end
        _ ->
          {:unknown, location.default_message}
      end
    else
      {:error, _error} ->

        {:unknown, location.default_message}
    end
  end
  defp close_conversation(convo_id, location) do

    disposition =
      %{role: "system"}
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Enum.find(&(&1.disposition_name == "Automated"))

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

    C.close(convo_id)
  end
  def reply_to_facebook(msg,location,recipient)do
    url = "https://graph.facebook.com/v11.0/me/messages?access_token=#{location.facebook_token}"
    body =%{
      messaging_type: "RESPONSE",
      recipient: %{
        id: recipient
      },
      message: %{
        text: msg
      }} |> Jason.encode!
    case HTTPoison.post(url,body,[{"Content-Type", "application/json"}])do
      {:ok, res} -> Poison.decode!(res.body)
      _ -> :error
    end
  end
end


#https://2e83-39-45-196-127.ngrok.io/admin/teams/993ed7d1-f9bc-48de-865e-313b53c7bd47/locations/a7c86ffb-e417-4ff3-9aec-c410a8aee176/hook