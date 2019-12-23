defmodule MainWeb.FlowController do
  @moduledoc """
  This controller is the communication pipeline for the bot.
  """
  use MainWeb, :controller

  alias MainWeb.Plug, as: P
  alias Chatbot.Client.Twilio

  require Logger

  plug P.AssignParams

  def flow(%{assigns: %{flow_name: flow_name} = attrs} = conn, _params) do
    execute(%Chatbot.Params{
      provider: :twilio,
      to: attrs.member,
      from: attrs.location,
      body: build_chat_params(flow_name, attrs)
    })

    conn
    |> put_status(200)
    |> json(%{status: :success})
  end

  defp build_chat_params(name, params) do
    %{
      flow_name: String.replace(name, "_", " "),
      fname: params.first_name,
      lname: params.last_name,
      location_name: params.location_name,
      phone: params.member,
      barcode: params.barcode,
      location_name: params.location_name,
      home_club: params.home_club,
      new_club: params.new_club,
      message: params.message
    }
  end

  defp execute(params), do: Twilio.execution(params)
end
