defmodule Session.ProcessCommand do
  @moduledoc false

  import Session.Actions

  require Logger

  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @commands Application.get_env(:session, :commands, Session.Commands)
  @storage Application.get_env(:session, :storage, Data.Intent)
  @deps %{
    chatbot: @chatbot,
    commands: @commands,
    storage: @storage

  }

  @doc """
  Handle messages when session is open and not in a current command state
  """
  def call(%Session{request: request} = session, deps \\ @deps) do
    with %Session{} = session <- log(session, "INBOUND", deps),
         {:open, conversation} <- start_or_update_conversation(session) do
      {:ok, session}
    else
      {_, conversation} ->
        request.body
        |> ask_question()
        |> process_command(session, conversation)
    end
  end

  defp process_command(command, %Session{request: request} = session, conversation, deps \\ @deps) do
    command
    |> deps.storage.get_message(request.to)
    |> build_message(request)
    |> update_conversation(conversation)
    |> send_message(deps)

    {:ok, session}
  end
end
