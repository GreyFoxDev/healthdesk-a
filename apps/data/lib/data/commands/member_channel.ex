defmodule Data.Commands.MemberChannel do
  @moduledoc false

  use Data.Commands, schema: MemberChannel

  alias Data.Schema.{MemberChannel, Location}
  alias Data.Commands.Location, as: L

  def all(member_id),
    do: Command.execute_task_with_results(fn -> Read.all(member_id) end)

  @doc """
  Finds a opt in by memberChannel's phone number
  """
  @spec get_by_channel_id(channel_id :: binary) :: MemberChannel.t()
  def get_by_channel_id(channel_id),
    do: {:ok, Read.get_by_channel_id(channel_id)}

end
