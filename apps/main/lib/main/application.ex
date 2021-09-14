defmodule Main.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Phoenix.PubSub, name: Main.PubSub},
      supervisor(MainWeb.Endpoint, []),
      MainWeb.Presence,
      {Main.WebChat.Supervisor, []},
      {Main.Scheduler, []},
      {Registry, [keys: :unique, name: Registry.WebChat]},
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

defmodule Main.WebChat.Supervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(socket) do
    DynamicSupervisor.start_child(__MODULE__, {Main.WebChat.Events, socket})
  end
end
