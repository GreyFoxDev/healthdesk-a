defmodule Main.Scheduler do
  use Quantum, otp_app: :main

  alias Data.{Campaign,Member, CampaignRecipient, Location, Conversations}
  alias Quantum.Job

  @role %{role: "admin"}
  @chatbot Application.get_env(:session, :chatbot, Chatbot)

  def schedule_campaign(id) do
    campaign = Campaign.get(id)
    time= campaign.send_at


    cron_expr = %Crontab.CronExpression{
    }
    cron_expr =  if time.year != 0 , do: Map.put(cron_expr,:year,[time.year]), else: cron_expr
    cron_expr =  if time.month != 0 , do: Map.put(cron_expr,:month,[time.month]), else: cron_expr
    cron_expr =  if time.day != 0 , do: Map.put(cron_expr,:day,[time.day]), else: cron_expr
    cron_expr =  if time.hour != 0 , do: Map.put(cron_expr,:hour,[time.hour]), else: cron_expr
    cron_expr =  if time.minute != 0 , do: Map.put(cron_expr,:minute,[time.minute]), else: cron_expr
    cron_expr =  if time.second != 0 , do: Map.put(cron_expr,:second,[time.second]), else: cron_expr
    job = new_job()
          |> Job.set_name(String.to_atom(campaign.campaign_name))
          |> Job.set_schedule(cron_expr)
          |> Job.set_task(fn -> send_campaign(id) end)
    job
    |> add_job()

  end

  def schedule_conversation() do
    Conversations.update_conversation()
  end

  def send_campaign(id) do
    campaign = Campaign.get(id)
    send_to_recipients(campaign)|> complete_campaign()
  end

  defp send_to_recipients(campaign) do
    location = Location.get(campaign.location_id)
    campaign.id
    |> CampaignRecipient.get_by_campaign_id()
    |> Enum.map(
         fn (member) ->
           member_ =  Member.get_by_phone_number(@role, member.phone_number)
           if member_ && member.consent != false do

             %{
               provider: :twilio,
               from: location.phone_number,
               to: member.phone_number,
               body: campaign.message
             }
             |> @chatbot.send()
             CampaignRecipient.update(member, %{sent_at: DateTime.utc_now(), sent_successfully: true})

           else
             if !member_  do

               %{
                 provider: :twilio,
                 from: location.phone_number,
                 to: member.phone_number,
                 body: campaign.message
               }
               |> @chatbot.send()
               CampaignRecipient.update(member, %{sent_at: DateTime.utc_now(), sent_successfully: true})
             else
               false

             end


           end
         end
       )

    campaign
  end

  defp complete_campaign(campaign),
       do: Campaign.update(campaign, %{completed: true})

end