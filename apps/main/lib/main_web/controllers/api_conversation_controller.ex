defmodule MainWeb.Api.ConversationController do
  use MainWeb, :controller

  alias Data.Conversations, as: C
  alias Data.ConversationCall
  alias Data.ConversationMessages, as: CM
  alias Data.{Location, Team}
  alias Data.Member
  alias MainWeb.{Notify, Intents}
  @role %{role: "admin"}

  def create_(conn,params)do
    IO.inspect("#########paramas recieved##########")
    IO.inspect(params)
    IO.inspect("###################")
    create(conn,params)
  end
  def create(conn, %{"location" => << "messenger:", location :: binary>>, "member" => << "messenger:", _ :: binary>> = member}) do
    location = Location.get_by_messenger_id(location)

    with {:ok, convo} <- C.find_or_start_conversation({member, location.phone_number}) do
      Main.LiveUpdates.notify_live_view({convo.location_id, :updated_open})
      conn
      |> put_status(200)
      |> put_resp_content_type("application/json")
      |> json(%{conversation_id: convo.id})
    end
  end
  def create(conn, %{"location" => location, "member" => member, "type" => "call"}) do
    with {:ok, convo} <- ConversationCall.find_or_start_conversation({member, location}) do
      IO.inspect("=======================createIN API Controller=====================")
      IO.inspect(convo)
      IO.inspect("=======================createIN API Controller=====================")
      Task.start(fn ->  close_convo(convo) end)
      conn
      |> put_status(200)
      |> put_resp_content_type("application/json")
      |> json(%{conversation_id: convo.id})
    end
  end
  def create(conn, %{"location" => location, "member" => member, "preEngagementData" => %{"memberName" => _name, "phoneNumber" => _number}}) do
    with {:ok, convo} <- C.find_or_start_conversation({member, location}) do
      Task.start(fn ->  notify_open(convo.location_id) end)
      conn
      |> put_status(200)
      |> put_resp_content_type("application/json")
      |> json(%{conversation_id: convo.id})
    end
  end
  def create(conn, %{"location" => location, "member" => member}) do
    with {:ok, convo} <- C.find_or_start_conversation({member, location}) do
      IO.inspect("####open#####")
      IO.inspect(convo)
      IO.inspect("#########")
      Task.start(fn ->  notify_open(convo.location_id) end)
      conn
      |> put_status(200)
      |> put_resp_content_type("application/json")
      |> json(%{conversation_id: convo.id})
    end
  end
  def create(conn, %{"from" => from, "subject" => subj, "text" => message,"to" => to} = _params) do
    regex = ~r{([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)}
    name = List.first(Regex.split(regex,from))
    from = List.first(Regex.run(regex,from))
    message = ElixirEmailReplyParser.parse_reply message
    to = Regex.scan(regex,to) |> List.flatten |> Enum.uniq
    IO.inspect(from, limit: :infinity)
    IO.inspect(to, limit: :infinity)
    IO.inspect(subj, limit: :infinity)
    subj = String.slice(subj, 0..200)
    if from != nil && from != "" && message != nil && message != "" do
      with {:ok, convo} <- C.find_or_start_conversation(from, to,subj) do
        Task.start(fn ->  notify_open(convo.location_id) end)
        {:ok, struct}= CM.create(%{
          "conversation_id" => convo.id,
          "phone_number" => from,
          "message" => message,
          "sent_at" => DateTime.utc_now()})
        location = Location.get(convo.location_id)
        Main.LiveUpdates.notify_live_view({convo.id, struct})
        with %Data.Schema.Member{} = member <- Member.get_by_phone_number(@role, from) do
          Member.update(member.id, %{first_name:  String.replace(name||"","<","")|>String.trim,email: from})
        else
          nil ->
            Member.create(%{
              team_id: location.team_id,
              first_name: String.replace(name||"","<","")|>String.trim,
              email: from,
              phone_number: from
            })
        end
        if convo.status == "closed"  do
          message
          |> ask_wit_ai(location)
          |> case do
               {:ok, response} ->
                 if convo.status == "closed" do
                   {:ok, struct}=  CM.create(
                     %{
                       "conversation_id" => convo.id,
                       "phone_number" => location.phone_number,
                       "message" => response,
                       "sent_at" => DateTime.add(DateTime.utc_now(), 2)
                     }
                   )
                   close_conversation(convo.id, location)
                   from
                   |> Main.Email.generate_reply_email(response, subj,location.phone_number)
                   |> Main.Mailer.deliver_now()
                   Main.LiveUpdates.notify_live_view({convo.id, struct})
                 end

               {:unknown, response} ->

                 if convo.status == "closed" do
                   {:ok, struct}=  CM.create(
                     %{
                       "conversation_id" => convo.id,
                       "phone_number" => location.phone_number,
                       "message" => response,
                       "sent_at" => DateTime.add(DateTime.utc_now(), 2)
                     }
                   )
                   C.pending(convo.id)
                   from
                   |> Main.Email.generate_reply_email(response, subj,location.phone_number)
                   |> Main.Mailer.deliver_now()
                   Main.LiveUpdates.notify_live_view({convo.id, struct})
                 end

                 Main.LiveUpdates.notify_live_view({location.id, :updated_open})
                 :ok =
                   Notify.send_to_admin(
                     convo.id,
                     "#{message}",
                     location.phone_number,
                     "location-admin"
                   )
             end
        else
          :ok =
            case convo.status do
              "open" ->
                Notify.send_to_teammate(convo.id, message, location, convo.team_member, convo.member )
              _ ->
                Notify.send_to_admin(convo.id, message, location.phone_number, "location-admin")
            end
        end
      else
        _ -> nil
      end
    end
    conn |> send_resp(200, "ok")
  end

  def update(conn, %{"conversation_id" => id, "from" => from, "message" => message, "type" =>"call"}) do
    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id, updated: true})
  end
  def update(conn, %{"conversation_id" => id, "from" => from, "message" => message}) do
    _ = CM.create(%{
      "conversation_id" => id,
      "phone_number" => from,
      "message" => message,
      "sent_at" => DateTime.utc_now()})

    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id, updated: true})
  end
  def update(conn, _params) do
    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{success: false})
  end

  def close(conn, %{"conversation_id" => id, "from" => from, "message" => message, "type"=>"call"} = params) do
    IO.inspect("=======================params in CLSOE=====================")
    IO.inspect(params)
    IO.inspect("=======================params in CLSOE=====================")
    if params["disposition"] do
      convo = ConversationCall.get(id)
      location = Location.get(convo.location_id)
      dispositions = Data.Disposition.get_by_team_id(%{role: "system"}, location.team_id)
      disposition = Enum.find(dispositions, &(&1.disposition_name == params["disposition"]))

      IO.inspect("=======================disposition=====================")
      IO.inspect(disposition)
      IO.inspect("=======================disposition=====================")

      Data.ConversationDisposition.create(%{"conversation_call_id" => id, "disposition_id" => disposition.id})

      ConversationCall.close(id)
    else
      IO.inspect("=======================elseClasueOFClose=====================")
      IO.inspect("elseClasueOFClose")
      IO.inspect("=======================elseClasueOFClose=====================")
      ConversationCall.close(id)
    end

    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id})
  end
  def close(conn, %{"conversation_id" => id, "from" => from, "message" => message} = params) do
    if message == "Sent to Slack" do
      _ =  CM.create(%{
        "conversation_id" => id,
        "phone_number" => from,
        "message" => params["slack_message"],
        "sent_at" => DateTime.utc_now()})

      :ok = MainWeb.Notify.send_to_admin(id, params["slack_message"], from)
    else
      _ =  CM.create(%{
        "conversation_id" => id,
        "phone_number" => from,
        "message" => message,
        "sent_at" => DateTime.utc_now()})
    end

    if params["disposition"] do
      convo = C.get(id)
      location = Location.get(convo.location_id)
      dispositions = Data.Disposition.get_by_team_id(%{role: "system"}, location.team_id)
      disposition = Enum.find(dispositions, &(&1.disposition_name == params["disposition"]))

      Data.ConversationDisposition.create(%{"conversation_id" => id, "disposition_id" => disposition.id})

      _ =  %{"conversation_id" => id,
        "phone_number" => location.phone_number,
        "message" => "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.add(DateTime.utc_now(), 3)}
      |> CM.create()
      C.close(id)
#      Main.LiveUpdates.notify_live_view({convo.location_id, :updated_open})
    else
      C.close(id)
    end

    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{conversation_id: id})
  end

  def notify_open(location_id)do
    :timer.sleep(5000);
    Main.LiveUpdates.notify_live_view({location_id, :updated_open})
  end
  def close_convo(%{original_number: <<"+", _ :: binary>>} = convo_) do
    :timer.sleep(100000);
    conversation = ConversationCall.get(convo_.id)
    case conversation do
      nil -> nil
      convo ->
        if convo.status != "closed" do

            location = Location.get(convo.location_id)
            dispositions = Data.Disposition.get_by_team_id(%{role: "system"}, location.team_id)
            disposition = Enum.find(dispositions, &(&1.disposition_name == "Call Hang Up"))
            IO.inspect("=======================disposition=====================")
            IO.inspect(disposition)
            IO.inspect("=======================disposition=====================")

            conve=Data.ConversationDisposition.create(%{"conversation_call_id" => convo.id, "disposition_id" => disposition.id})
            IO.inspect("=======================close_convo=====================")
            IO.inspect(conve)
            IO.inspect("=======================close_convo=====================")

            ConversationCall.close(convo.id)
#            notify && Main.LiveUpdates.notify_live_view({location.id, :updated_open})
        end 
    end
  end
  def close_convo(_), do: nil
  defp ask_wit_ai(question, location) do
    bot_id=Team.get_bot_id_by_location_id(location.id)
    with {:ok, _pid} <- WitClient.MessageSupervisor.ask_question(self(), question, bot_id) do
      receive do
        {:response, response} ->
          message = Intents.get(response, location.phone_number)
          if message == location.default_message do
            {:unknown, location.default_message}
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
      Data.ConversationDisposition.create(
        %{
          "conversation_id" => convo_id,
          "disposition_id" => disposition.id
        }
      )

      _ = %{
        "conversation_id" => convo_id,
        "phone_number" => location.phone_number,
        "message" =>
          "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
        "sent_at" => DateTime.add(DateTime.utc_now(), 3)
      }
      |> CM.create()
    else
      _ =  %{
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
end
