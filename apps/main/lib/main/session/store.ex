defmodule Session.Store do
  use GenServer

  def start_link(_),
    do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_) do
    :ets.new(:session_cache, [:named_table]) 
    {:ok, :ok}
  end
end
