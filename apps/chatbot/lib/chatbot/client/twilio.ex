defmodule Chatbot.Client.Twilio do

  @moduledoc """

  This module is the twilio client. Using the `call/1` function and
  passing the `%Chatbot.Params{}` struct a message will be sent to
  the Twilio service.

  """

  def call(%Chatbot.Params{provider: :twilio} = params) do
    ExTwilio.Message.create(
      from: params.from,
      to: params.to,
      body: params.body)
  end
end
