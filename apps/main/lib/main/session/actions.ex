defmodule Session.Actions do

  @moduledoc false

  require Logger

  @admin_url Application.get_env(:session, :admin_url, "http://example.com")

  def ask_question(body) do
    # DialogFlow.MessageSupervisor.ask_question(self(), body)
    receive do
      {:response, :unknown} ->
        "HELP"
      {:response, {intent, args}} ->
        {intent, args}
      {:error, error} ->
        Logger.info error
        "HELP"
    end
  end

  @doc """
  Send request to be logged. returns `{:ok, result}`
  """
  def log(%{request: request} = session, direction, deps) do
    %{
      direction: direction,
      command: (session.current_command || "UNKNOWN"),
      message: request.body,
      from: request.from,
      to: request.to
    }
    |> deps.storage.log_request()
  end

  @doc """
  Send message to chatbot
  """
  def send_message(nil, _deps), do: nil
  def send_message(response, deps),
    do: deps.chatbot.send(response)

  def alert_admins(request, deps) do
    Logger.info "Admin URL is #{inspect @admin_url}"
    body = """
    Message From: #{request.from}
    #{request.body}

    https://elixir-chatbot.herokuapp.com

    """

    deps.storage.admin_numbers
    |> Enum.map(fn(number) ->
      send_message(%{
            provider: request.provider,
            body: body,
            to: number,
            from: request.to}, deps)
    end)
  end

  @doc """
  build the message to send
  """
  def build_message(nil, _), do: nil
  def build_message(body, %{provider: provider, from: from, to: to}) do
    %{
      provider: provider,
      body: """
      #{body}
      """,
      to: from,
      from: to}
  end
end
