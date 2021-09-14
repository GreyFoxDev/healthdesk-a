defmodule Chatbot.Client.Twilio do
  alias Data.{Location, Team}

  @moduledoc """

  This module is the twilio client. Using the `call/1` function and
  passing the `%Chatbot.Params{}` struct a message will be sent to
  the Twilio service.

  """

  require Logger

  def call(%Chatbot.Params{provider: :twilio} = params) do
    #    body = Poison.encode!(params.body)
    location_id = Location.get_by_phone(params.from).id
    account = Team.get_sub_account_id_by_location_id(location_id)

    ExTwilio.Message.create(
      [from: params.from, to: params.to, body: params.body],
      flow_sid: params.twilio_flow_id,
      account_sid: account
    )
  end

  def execution(%Chatbot.Params{provider: :twilio} = params) do
    body = Poison.encode!(params.body)
    location_id = Location.get_by_phone(params.from).id
    account = Team.get_sub_account_id_by_location_id(location_id)

    ExTwilio.Api.create(
      ExTwilio.Studio.Execution,
      [to: params.to, from: params.from, parameters: body],
      flow_sid: params.body.twilio_flow_id,
      account_sid: account
    )
  end

  def channel(%Chatbot.Params{provider: :twilio} = params) do
    account = Application.get_env(:ex_twilio, :flex_account_sid)
    token = Application.get_env(:ex_twilio, :flex_auth_token)
    service_id = Application.get_env(:ex_twilio, :flex_service_id)

    ExTwilio.Api.create(
      ExTwilio.ProgrammableChat.Channel,
      [to: params.to, from: params.from, body: params.body, friendly_name: "Nick"],
      service_id: service_id,
      to: params.to,
      account: account,
      token: token
    )
  end

  def verify(phone_number, country) do
    [authy_url(), "via=sms&code_length=6&phone_number=", phone_number, "&country_code=#{country}"]
    |> Enum.join()
    |> HTTPoison.post!("", authy_header())
    |> case do
      %{status_code: 200} ->
        :ok

      error ->
        Logger.error(inspect(error))
        {:error, :error_sending_verification}
    end
  end

  def check(phone_number, country, verification_code) do
    [
      check_url(),
      "phone_number=",
      phone_number,
      "&country_code=#{country}&verification_code=",
      verification_code
    ]
    |> Enum.join()
    |> HTTPoison.get!(authy_header())
    |> case do
      %{status_code: 200} ->
        :ok

      error ->
        Logger.error(inspect(error))
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
