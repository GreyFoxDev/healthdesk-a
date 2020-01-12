defmodule Chatbot.Params do
  @moduledoc """

  This module is used to build the chatbot params used to send a message.

  Example:

  iex> Chatbot.Params.build(%{provider: "twilio", from: "ME", to: "YOU", body: "Hello"})
  {:ok, %Chatbot.Params{provider: :twilio, from: "ME", to: "YOU", body: "Hello"}}

  """

  @providers [:twilio]

  defstruct [
    :provider,
    :from,
    :to,
    :body,
    :twilio_flow_id
  ]

  def build(%{provider: provider} = params)
      when provider in @providers do
    {:ok,
     %Chatbot.Params{
       provider: provider,
       from: params[:from],
       to: params[:to],
       body: params[:body],
       twilio_flow_id: params[:twilio_flow_id]
     }}
  end

  def build(_params),
    do: {:error, :unknown_provider}
end
