defmodule Session do

  @moduledoc """
  The structure that represents a session
  """

  defstruct [
    pid: nil,
    request: nil,
    current_command: nil,
    count: 0,
    error_count: 0,
    deps: nil,
    ttl: nil,
    index: 0
  ]
end
