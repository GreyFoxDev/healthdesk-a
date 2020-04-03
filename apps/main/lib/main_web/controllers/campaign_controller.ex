defmodule MainWeb.CampaignController do
  use MainWeb.SecuredContoller

  alias Data.{Campaign, CampaignRecipient}

  def export(conn, %{"campaign_id" => campaign_id}) do
    campaign = Campaign.get(campaign_id)
    file_name = Inflex.parameterize(campaign.campaign_name, "-")

    recipients =
      campaign_id
      |> CampaignRecipient.get_by_campaign_id()
      |> Enum.map(&build_row/1)
      |> Enum.join("\n")
      |> add_header()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{file_name}.csv\"")
    |> send_resp(200, recipients)
  end

  def delete(conn, %{"campaign_id" => campaign_id}) do
    campaign_id
    |> Campaign.get()
    |> Campaign.delete()
    |> case do
         {:ok, _} ->
           conn
           |> put_flash(:success, "Campaign deleted successfully.")
           |> redirect(to: "/admin")
         {:error, _} ->
           conn
           |> put_flash(:success, "Campaign failed to delete.")
           |> redirect(to: "/admin")
       end
  end

  defp build_row(recipient) do
    String.split(recipient.recipient_name) ++ [recipient.phone_number] |> Enum.join(",")
  end

  defp add_header(recipients),
    do: "First,Last,Phone\n" <> recipients

end
