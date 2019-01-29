defmodule MainWeb.Plug.OptIn do

  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @system_role %{role: "system"}
  @opt_in_message """
  To receive a response to your inquiry, you must opt-in. Reply YES for recurring automated SMS/MMS marketing messages powered by Healthdesk. No purchase required. Message and data rates may apply. Terms: https://healthdesk.ai/terms
  """
  @opt_out_message """
  You have successfully opted-out. You will not receive any more messages from this number. Reply START to resubscribe at any time.
  """

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), list()) :: no_return()
  def call(conn, opts \\ [])

  def call(conn, _opts), do: conn

  def call(%{params: %{"Body" => body, "From" => from, "To" => to} = params} = conn, _opts) do
    @system_role
    |> Data.OptIn.get_by_phone_number(to)
    |> handle_opt_in(params)
    |> opted_in?(conn, from)
  end

  defp handle_opt_in(%{status: "complete"}, _), do: true

  defp handle_opt_in(%{status: "decline"}, _), do: false

  defp handle_opt_in(nil, %{"Body" => body, "From" => member, "To" => location} = request) do
    params = %{"phone_number" => location, "status" => "pending"}

    with {:ok, _} <- Data.OptIn.create(@system_role, params),
         %Session{} = request <- build_request(request),
         {:open, conversation} <- Session.Actions.start_or_update_conversation(request) do

      %{
        "phone_number" => location,
        "message" => @opt_in_messages,
        "sent_at" => DateTime.utc_now(),
        "conversation_id" => conversation.id}
      |> Data.Commands.ConversationMessages.write()

      ConCache.put(:session_cache, member, body)

      build_response(member, location, @opt_in_message) |> @chatbot.send()
    end
    false
  end

  defp handle_opt_in(%{id: id, status: "pending"}, %{"Body" => body, "From" => member, "To" => location} = request)
  when body in ["NO", "No", "no"]  do
    with {:ok, _} <- Data.OptIn.update(@system_role, id, %{"status" => "decline"}),
         %Session{} = request <- build_request(request),
         {:open, conversation} <- Session.Actions.start_or_update_conversation(request) do

      %{
        "phone_number" => location,
        "message" => @opt_out_message,
        "sent_at" => DateTime.utc_now(),
        "conversation_id" => conversation.id}
      |> Data.Commands.ConversationMessages.write()

      build_response(member, location, @opt_out_message) |> @chatbot.send()
    end
    false
  end

  defp handle_opt_in(%{id: id, status: "pending"}, %{"Body" => body, "From" => member} = request)
  when body in ["YES", "yes", "Yes"]  do

    with {:ok, _} <- Data.OptIn.update(@system_role, id, %{"status" => "complete"}),
         %Session{} = request <- build_request(request),
         {:open, conversation} <- Session.Actions.start_or_update_conversation(request) do
      true
    else
      _ -> false
    end
  end

  defp handle_opt_in(%{status: "pending"}, _), do: false

  defp opted_in?(true, conn, member)  do
    case ConCache.get(:session_cache, member) do
      nil ->
        conn
      message ->
        conn = Plug.Conn.assign(conn, "Body", message)
    end
  end

  defp opted_in?(false, conn, _) do
    Plug.Conn.halt(conn)
  end

  defp build_response(member, location, message) do
    %{
      provider: :twilio,
      body: """
      #{message}
      """,
      to: member,
      from: location}
  end

  defp build_request(params) do
    %Session{request: %{
                from: params["From"],
                to: params["To"],
                body: params["Body"]
             }
    }
  end
end
