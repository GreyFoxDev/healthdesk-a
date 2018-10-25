defmodule Session.ProcessCommand do
  @moduledoc false

  import Session.Actions

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
  def call(%Session{request: request} = session, deps \\ @deops) do
    log(session, "INBOUND", deps)

    alert_admins(request, deps)

    request.body
    |> ask_question()
    |> process_command(session)
  end

  defp process_command(command, %Session{request: request} = session, deps \\ @deps) do
    command
    |> deps.storage.get_message(request.to)
    |> build_message(request)
    |> send_message(deps)

    {:ok, Map.merge(session, %{current_command: command})}
  end
end
