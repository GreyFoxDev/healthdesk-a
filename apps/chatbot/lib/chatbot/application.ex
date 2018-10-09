defmodule Chatbot.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Chatbot, []},
      {Chatbot.MessageSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Chatbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
