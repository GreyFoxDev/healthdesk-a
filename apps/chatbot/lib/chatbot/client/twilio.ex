defmodule Chatbot.Client.Twilio do
  @moduledoc """

  This module is the twilio client. Using the `call/1` function and
  passing the `%Chatbot.Params{}` struct a message will be sent to
  the Twilio service.

  """

  require Logger

  def call(%Chatbot.Params{provider: :twilio} = params) do
    ExTwilio.Message.create(
      from: params.from,
      to: params.to,
      body: params.body
    )
  end

  def verify(phone_number) do
    [authy_url(), "via=sms&phone_number=", phone_number, "&country_code=1"]
    |> Enum.join
    |> HTTPoison.post!("", authy_header())
    |> case do
         %{status_code: 200} ->
           :ok
         error ->
           Logger.error inspect(error)
           {:error, :error_sending_verification}
       end
  end

  def check(phone_number, verification_code) do
    [
      check_url(),
      "phone_number=",
      phone_number,
      "&country_code=1&verification_code=",
      verification_code
    ]
    |> Enum.join
    |> HTTPoison.get!(authy_header())
    |> case do
         %{status_code: 200} ->
           :ok
         error ->
           Logger.error inspect(error)
           {:error, :unauthorized}
       end
  end

  defp authy_key,
    do: Application.get_env(:ex_twilio, :authy_key)

  defp authy_header,
    do: ["X-Authy-API-Key": authy_key()]

  defp authy_url,
    do: "https://api.authy.com/protected/json/phones/verification/start?"

  defp check_url,
    do: "https://api.authy.com/protected/json/phones/verification/check?"
end
