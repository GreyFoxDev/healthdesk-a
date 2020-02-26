defmodule MainWeb.TsiController do
  use MainWeb, :controller

  import Plug.Conn, only: [send_resp: 3]

  plug MainWeb.Plug.AllowFrom
  plug MainWeb.Plug.ValidateApiKey

  alias Data.Conversations, as: C
  alias Data.ConversationMessages, as: CM
  alias Data.Schema.Conversation, as: Schema

  alias MainWeb.{Notify, Intents}

  alias Data.{Location, Conversation}

  def new(conn, %{"phone-number" => phone_number, "api_key" => api_key} = params) do
    conn
    |> put_layout({MainWeb.LayoutView, :tsi})
    |> render("new.html", api_key: api_key, phone_number: phone_number)
  end

  def new(conn, _params),
    do: send_resp(conn, 400, "Bad request")

  def edit(conn, %{"id" => convo_id, "api_key" => api_key} = params) do
    location = conn.assigns.location

    with %Schema{} = convo <- C.get(convo_id) do
      << "APP:", phone_number :: binary >> = convo.original_number

      conn
      |> put_layout({MainWeb.LayoutView, :tsi_conversation})
      |> render("edit.html", api_key: api_key, convo_id: convo_id, phone_number: phone_number, changeset: CM.get_changeset())
    end
  end

  def edit(conn, _params),
    do: send_resp(conn, 400, "Bad request")

  def create(conn, %{"phone_number" => phone_number, "api_key" => api_key} = params) do
    phone_number = "APP:#{format_phone(phone_number)}"
    location = conn.assigns.location

    with {:ok, %Schema{} = convo} <- C.find_or_start_conversation({phone_number, location.phone_number}) do
      message = extract_question(params)
      CM.create(%{
            "conversation_id" => convo.id,
            "phone_number" => phone_number,
            "message" => message,
            "sent_at" => DateTime.utc_now()})

      CM.create(%{
            "conversation_id" => convo.id,
            "phone_number" => location.phone_number,
            "message" => build_answer(params),
            "sent_at" => DateTime.add(DateTime.utc_now(), 2)})

      close_conversation(convo.id, location)

      redirect(conn, to: tsi_path(conn, :edit, api_key, convo.id))
    end
  end

  def create(conn, _params) do
    Plug.Conn.send_resp(conn, 400, "Bad request")
  end

  def update(conn, %{"id" => convo_id, "api_key" => api_key} = params) do
    location = conn.assigns.location

    with %Schema{} = convo <- C.get(convo_id) do
      << "APP:", phone_number :: binary >> = convo.original_number

      CM.create(%{
            "conversation_id" => convo.id,
            "phone_number" => convo.original_number,
            "message" => params["message"],
            "sent_at" => DateTime.utc_now()})

      if convo.status == "closed" do
        params["message"]
        |> ask_wit_ai(location)
        |> case do
             {:ok, response} ->
               CM.create(%{
                     "conversation_id" => convo.id,
                     "phone_number" => location.phone_number,
                     "message" => response,
                     "sent_at" => DateTime.add(DateTime.utc_now(), 2)})

               close_conversation(convo_id, location)
             {:unknown, response} ->
               CM.create(%{
                     "conversation_id" => convo.id,
                     "phone_number" => location.phone_number,
                     "message" => response,
                     "sent_at" => DateTime.add(DateTime.utc_now(), 2)})

               C.pending(convo_id)

               :ok =
                 Notify.send_to_admin(convo.id,
                   "Message From: #{convo.original_number}\n#{params["message"]}",
                   location.phone_number)
           end
      end

      redirect(conn, to: tsi_path(conn, :edit, api_key, convo.id))
    end
  end

  defp extract_question(%{"facilities" => question}), do: question
  defp extract_question(%{"personnel" => question}), do: question
  defp extract_question(%{"member_services" => question}), do: question
  defp extract_question(_), do: "No message sent"

  defp build_answer(%{"member_services" => _}) do
    """
    Please contact Member Services at 877.258.2311 between the hours of 9:30 am
    – 5:30 pm ET M-F.
    """
  end

  defp build_answer(_) do
    "We've received your request. You may leave a comment below if you'd like."
  end

  def format_phone(<< "1", area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    "+1#{Enum.join([area_code, prefix, line])}"
  end

  def format_phone(<< " 1", area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    "+1#{Enum.join([area_code, prefix, line])}"
  end

  def format_phone(<< "+1", area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    "+1#{Enum.join([area_code, prefix, line])}"
  end

  def format_phone(<< area_code::binary-size(3), prefix::binary-size(3), line::binary-size(4) >>) do
    "+1#{Enum.join([area_code, prefix, line])}"
  end

  defp ask_wit_ai(question, location) do
    with {:ok, _pid} <- WitClient.MessageSupervisor.ask_question(self(), question) do
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
      {:error, error} ->
        {:unknown, location.default_message}
    end
  end

  defp close_conversation(convo_id, location) do
    disposition =
      %{role: "system"}
      |> Data.Disposition.get_by_team_id(location.team_id)
      |> Enum.find(&(&1.disposition_name == "Automated"))

    Data.ConversationDisposition.create(%{
          "conversation_id" => convo_id,
          "disposition_id" => disposition.id
                                        })

    %{"conversation_id" => convo_id,
      "phone_number" => location.phone_number,
      "message" =>
        "CLOSED: Closed by System with disposition #{disposition.disposition_name}",
      "sent_at" => DateTime.add(DateTime.utc_now(), 3)}
    |> CM.create()

    C.close(convo_id)
  end

end
