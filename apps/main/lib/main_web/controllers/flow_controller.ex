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

  defp build_chat_params("support_24hr_waiver" = name, params) do
    %{
      flow_name: name,
      fname: params.first_name,
      lname: params.last_name,
    }
  end

  defp build_chat_params("support_additional_access" = name, params) do
    %{
      flow_name: name,
      fname: params["fName"],
      lname: params["lName"],
    }
  end

  defp build_chat_params("support_home_club_change" = name, params) do
    %{
      flow_name: name,
      fname: params["fName"],
      lname: params["lName"],
      home_club: params["home_club"],
      new_club: params["new_club"]
    }
  end

  defp execute(params), do: Twilio.execution(params)
end
