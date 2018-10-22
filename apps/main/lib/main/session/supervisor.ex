defmodule Session.Handler.Supervisor do
  use Supervisor

  @moduledoc false

  require Logger

  def start_link,
    do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    children = [
      worker(Session.Handler, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_or_update_session(request) do
    with [{pid, _}] <- find_session(request) do
      GenServer.cast(pid, {:update_session, request})
    else
      []  ->
        Supervisor.start_child(__MODULE__, [request])
      _ ->
        {:error, :internal}
    end
  end

  defp find_session(%{from: phone_number}),
    do: Registry.match(Session.Registry, :member_number, phone_number)

end
