defmodule Session do
  defstruct phone_number: nil,
    verification_code: nil,
    ttl: nil

  alias Session.{Supervisor, Handler}

  def start(request) do
    with [{pid, _}] <- find_session(request) do
      {:ok, pid}
    else
      [] ->
        DynamicSupervisor.start_child(Supervisor, {Handler, request})

      _ ->
        {:error, :internal}
    end
  end

  def validate_session(request) do
    with [{pid, _}] <- find_session(request) do
      GenServer.cast(pid, :keep_alive)
      {:ok, pid}
    else
      [] ->
        {:error, :invalid_session}

      _ ->
        {:error, :internal}
    end
  end

  defp find_session(%{phone_number: phone_number}),
    do: Registry.match(Session.Registry, :phone_number, phone_number)
end
