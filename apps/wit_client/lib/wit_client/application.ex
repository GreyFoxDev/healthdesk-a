defmodule WitClient.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {WitClient.MessageSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: WitClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
