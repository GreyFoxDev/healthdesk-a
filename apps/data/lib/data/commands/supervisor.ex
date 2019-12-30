defmodule Data.Commands.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {Task.Supervisor, name: Data.Commands, restart: :transient}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def execute_task_with_results(func) do
    Data.Commands
    |> Task.Supervisor.async(func)
    |> Task.await(10_000)
  end

  def execute_task(func) do
    Task.Supervisor.start_child(Data.Commands, func)
  end
end
