defmodule Session.Handler do
  @moduledoc false

  use GenServer, restart: :transient

  @ttl Application.get_env(:session, :ttl, 3_600_000)

  def start_link(request),
    do: GenServer.start_link(__MODULE__, request)

  @impl true
  def init(request) do
    send(self(), :config)

    {:ok,
     %Session{
       phone_number: request.phone_number,
       verification_code: request[:verification_code],
       ttl: reset_ttl(self(), nil)
     }}
  end

  @impl true
  def handle_info(:config, %Session{phone_number: phone_number} = state) do
    {:ok, _pid} = Registry.register(Session.Registry, :phone_number, phone_number)
    {:noreply, state}
  end

  @impl true
  def handle_info(:kill_session, state),
    do: {:stop, :normal, state}

  @impl true
  def handle_cast(:keep_alive, state),
    do: {:noreply, %{state | ttl: reset_ttl(self(), state)}}

  defp reset_ttl(pid, nil),
    do: Process.send_after(pid, :kill_session, @ttl)

  defp reset_ttl(pid, %{ttl: ttl}) do
    Process.cancel_timer(ttl)
    reset_ttl(pid, nil)
  end
end
