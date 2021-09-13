defmodule MainWeb.FlowController do
  @moduledoc """
  This controller is the communication pipeline for the bot.
  """
  use MainWeb, :controller

  alias MainWeb.Plug, as: P
  alias Chatbot.Client.Twilio
  alias Data.Location

  require Logger

  plug P.AssignParams

  def flow(%{assigns: %{flow_name: flow_name} = attrs} = conn, _params) do
#    params = build_chat_params(flow_name, attrs)
    _ = execute(%Chatbot.Params{
          provider: :twilio,
          to: attrs.member,
          from: attrs.location,
          body:  attrs.message})

    conn
    |> put_status(200)
    |> json(%{status: :success})
  end

  defp build_chat_params(name, params) do
    location = Location.get_by_phone(params.location)

    %{
      flow_name: String.replace(name, "_", " "),
      fname: params.first_name,
      lname: params.last_name,
      location_name: params.location_name,
      phone: params.member,
      barcode: params.barcode,
      home_club: params.home_club,
      new_club: params.new_club,
      message: params.message,
      twilio_flow_id: location.team.twilio_flow_id
    }
  end

  defp execute(params), do: Twilio.call(params)
end
