defmodule Main.CampaignManager do
  use GenServer

  alias Data.{Campaign, CampaignRecipient, Location}

  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def start_link(_),
    do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_) do
    :timer.send_interval(60_000, :process_campaigns)
    {:ok, []}
  end

  def handle_info(:process_campaigns, state) do
    Campaign.active_campaigns()
    |> Enum.map(&send_to_recipients/1)
    |> Enum.map(&compelete_campaign/1)

    {:noreply, state}
  end

  defp send_to_recipients(campaign) do
    location = Location.get(campaign.location_id)

    campaign.id
    |> CampaignRecipient.get_by_campaign_id()
    |> Enum.map(fn(member) ->
      %{provider: :twilio,
        from: location.phone_number,
        to: member.phone_number,
        body: campaign.message
       } |> @chatbot.send()

      CampaignRecipient.update(member, %{sent_at: DateTime.utc_now(), sent_successfully: true})
    end)

    campaign
  end

  defp compelete_campaign(campaign),
    do: Campaign.update(campaign, %{completed: true})
end
