defmodule Chatbot.ParamsTest do
  use ExUnit.Case

  doctest Chatbot.Params

  test "build a valid params struct" do
    assert {:ok, struct} =
             Chatbot.Params.build(%{provider: "twilio", from: "ME", to: "YOU", body: "Hello"})

    assert %Chatbot.Params{} = struct
    assert :twilio == struct.provider
  end

  test "return error with unknown provider" do
    assert {:error, :unknown_provider} = Chatbot.Params.build(%{provider: ""})
  end
end
