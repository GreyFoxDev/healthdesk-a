defmodule WitClient.MessageSupervisor do
  use Supervisor

  @moduledoc false

  @supervisor WitClient.MessageSupervisor
  @child_spec [{WitClient.MessageHandler, []}]

  def start_link(_args),
    do: Supervisor.start_link(__MODULE__, [], name: @supervisor)

  def init(_args),
    do: Supervisor.init(@child_spec, strategy: :simple_one_for_one)

  def ask_question(pid, question, bot_id),
    do: Supervisor.start_child(@supervisor, [pid, question, bot_id])
end
