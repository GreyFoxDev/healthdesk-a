defmodule MainWeb.Notify do
  @moduledoc """
  This module is used to notify a location admin.
  """

  require Logger

  alias Data.Commands.Location

  @url "[url]/admin/teams/[team_id]/locations/[location_id]/conversations/[conversation_id]/conversation-messages"
  @super_admin Application.get_env(:main, :super_admin)
  @chatbot Application.get_env(:session, :chatbot, Chatbot)
  @endpoint Application.get_env(:main, :endpoint)

  @doc """
  Send a notification to the super admin defined in the config. It will create a short URL.
  """
  def send_to_admin(conversation_id, message, location, member \\ @super_admin) do
    IO.inspect(location) |> IO.inspect(label: "LOCATION # SENT")
    location = Location.get_by_phone(location) |> IO.inspect(label: "LOCATION")

    %{data: link} =
      @url
      |> String.replace("[url]", @endpoint)
      |> String.replace("[team_id]", location.team_id)
      |> String.replace("[location_id]", location.id)
      |> String.replace("[conversation_id]", conversation_id)
      |> Bitly.Link.shorten()

    message = %{
      provider: :twilio,
      from: location.phone_number,
      to: member,
      body: Enum.join([message, link[:url]], "\n")
    }


    alert_info = %{location: location, convo: conversation_id}
    MainWeb.Endpoint.broadcast("alert:admin", "broadcast", alert_info)

    @chatbot.send(message)

    :ok
  end

end
