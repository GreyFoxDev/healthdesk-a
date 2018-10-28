defmodule Session.Actions do

  @moduledoc false

  require Logger

  def ask_question(question) do
    WitClient.MessageSupervisor.ask_question(self(), question)
    receive do
      {:response, :unknown} ->
        "HELP"
      {:response, response} ->
        response
      {:error, _error} ->
        "HELP"
    end
  end

  @doc """
  Send request to be logged. returns `{:ok, result}`
  """
  def log(%{request: request} = session, direction, _deps) do
    %{
      direction: direction,
      command: (session.current_command || "UNKNOWN"),
      message: request.body,
      from: request.from,
      to: request.to
    }
    |> inspect()
    |> Logger.info()
  end

  @doc """
  Send message to chatbot
  """
  def send_message(nil, _deps), do: nil
  def send_message(response, deps),
    do: deps.chatbot.send(response)

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
