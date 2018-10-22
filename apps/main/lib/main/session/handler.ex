defmodule Session.Handler do
  use GenServer

  @moduledoc """
  The Session.Handler module represents the process for storing a session.
  """

  alias Session.Actions

  @ttl Application.get_env(:session, :ttl, 3_600_000)

  def start_link(request),
    do: GenServer.start_link(__MODULE__, request)

  def init(request) do
    send(self(), :config)
    {:ok, %Session{
        request: request,
        ttl: reset_ttl(self(), nil)}}
  end

  def handle_info(:kill_session, state),
    do: {:stop, :normal, state}

  def handle_info(:config, %Session{request: request} = state) do
    {:ok, _pid} = Registry.register(Session.Registry, :member_number, request.from)

    {:ok, new_state} = Session.ProcessCommand.call(state)

    {:noreply, new_state}
  end

  def handle_cast({:update_session, request}, state) do

    {:ok, new_state} =
      state
      |> Map.put(:request, request)
      |> Map.put(:ttl, reset_ttl(self(), state))
      |> Session.ProcessCommand.call()

    {:ok, _log} = Actions.log(new_state, "INBOUND", @deps)
    {:noreply, new_state}
  end

  defp reset_ttl(pid, nil),
    do: Process.send_after(pid, :kill_session, @ttl)

  defp reset_ttl(pid, %{ttl: ttl}) do
    Process.cancel_timer(ttl)
    reset_ttl(pid, nil)
  end
end
