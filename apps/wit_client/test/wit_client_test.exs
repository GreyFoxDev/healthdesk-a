defmodule WitClientTest do
  use ExUnit.Case
  doctest WitClient

  test "greets the world" do
    assert WitClient.hello() == :world
  end
end
