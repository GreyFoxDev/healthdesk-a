defmodule Main.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(MainWeb.Endpoint, []),
      worker(Registry, [:duplicate, Session.Registry]),
      supervisor(Session.Handler.Supervisor, []),
      {ConCache, [
            name: :session_cache,
            ttl_check_interval: :timer.hours(1),
            global_ttl: :timer.hours(24)
          ]}
    ]

    opts = [strategy: :one_for_one, name: Main.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
