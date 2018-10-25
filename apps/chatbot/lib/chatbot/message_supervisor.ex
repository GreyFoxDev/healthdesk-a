defmodule Chatbot.MessageSupervisor do
  use Supervisor

  @moduledoc """

  The Message Supervisor is used to supervise the handler
  processes that send the messages. The handlers are
  dynamically created and die after completing the send.
  If the process dies due to a non-normal stop then it is
  restarted.

  """

  @supervisor Chatbot.MessageSupervisor
  @child_spec [{Chatbot.MessageHandler, []}]

  def start_link(_args),
    do: Supervisor.start_link(__MODULE__, [], name: @supervisor)

  def init(_args),
    do: Supervisor.init(@child_spec, strategy: :simple_one_for_one)

  def send_message(params),
    do: Supervisor.start_child(@supervisor, [params])
end
