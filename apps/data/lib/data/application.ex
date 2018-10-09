defmodule Data.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Data.ReadOnly.Repo, []},
      {Data.WriteOnly.Repo, []},
      {Data.Commands.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Data.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
