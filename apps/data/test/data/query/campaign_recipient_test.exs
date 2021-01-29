defmodule Data.Query.CampaignRecipientTest do
  @moduledoc """
  Tests for the Holiday Hour Query module
  """
  use Data.DataCase

  alias Data.Query.CampaignRecipient, as: Query
  alias Data.Schema.CampaignRecipient

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})
    campaign = insert(:campaign, %{location_id: location.id})

    {:ok, campaign: campaign, location: location}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns holiday hour with a valid id", %{campaign: campaign} do
      recipient =
        insert(:campaign_recipient, %{
          campaign_id: campaign.id,
          recipient_name: "Bob Dobbs",
          phone_number: "000 555-1212"
        })

      assert found = Query.get(recipient.id, Repo)
      assert "Bob Dobbs" = found.recipient_name
      assert "000 555-1212" = found.phone_number
    end
  end

  describe "get_by_campaign_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_campaign_id(UUID.uuid4(), Repo)
    end

    test "returns recipients for a campaign id", %{campaign: campaign, location: location} do
      campaign2 = insert(:campaign, %{location_id: location.id})

      recipient =
        insert(:campaign_recipient, %{
          campaign_id: campaign.id,
          recipient_name: "Bob Dobbs",
          phone_number: "000 555-1212"
        })

      _ =
        insert(:campaign_recipient, %{
          campaign_id: campaign2.id,
          recipient_name: "Jane Dobbs",
          phone_number: "111 111-1111"
        })

      assert [found] = Query.get_by_campaign_id(campaign.id, Repo)
      assert recipient.id == found.id
      assert found.recipient_name == "Bob Dobbs"
      assert found.phone_number == "000 555-1212"
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               campaign_id: {"can't be blank", [validation: :required]},
               phone_number: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created holiday hour on success", %{campaign: campaign} do
      params = %{
        campaign_id: campaign.id,
        recipient_name: "Bob Dobbs",
        phone_number: "000 555-1212"
      }

      assert {:ok, %CampaignRecipient{} = new_record} = Query.create(params, Repo)
      assert "Bob Dobbs" == new_record.recipient_name
    end
  end

  describe "update/1" do
    setup context do
      {:ok, recipient: insert(:campaign_recipient, %{campaign_id: context.campaign.id})}
    end

    test "returns error if the required fields are not set", %{recipient: recipient} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(recipient, %{campaign_id: nil})

      assert errors == [
               campaign_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated recipient on success", %{recipient: recipient} do
      params = %{
        phone_number: "111 111-1111"
      }

      assert {:ok, %CampaignRecipient{} = updated} = Query.update(recipient, params, Repo)
      assert updated.id == recipient.id
      assert updated.recipient_name == recipient.recipient_name

      assert params.phone_number == updated.phone_number
    end
  end
end
