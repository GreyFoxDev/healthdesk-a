defmodule Data.Query.CampaignTest do
  @moduledoc """
  Tests for the Campaign Query module
  """
  use Data.DataCase

  alias Data.Query.Campaign, as: Query
  alias Data.Schema.Campaign

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns campaign with a valid id", %{location: location} do
      campaign = insert(:campaign, %{location_id: location.id, campaign_name: "My Campaign"})

      assert found = Query.get(campaign.id, Repo)
      assert "My Campaign" = found.campaign_name
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns campaigns for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      campaign = insert(:campaign, %{location_id: location.id, campaign_name: "My Campaign"})
      _ = insert(:campaign, %{location_id: location2.id, campaign_name: "Other Campaign"})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert campaign.id == found.id
      assert found.campaign_name == "My Campaign"
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created campaign on success", %{location: location} do
      params = %{
        location_id: location.id,
        campaign_name: "My Campaign"
      }

      assert {:ok, %Campaign{} = new_record} = Query.create(params, Repo)
      assert "My Campaign" == new_record.campaign_name
      refute new_record.deleted_at
    end
  end

  describe "update/1" do
    setup context do
      {:ok, campaign: insert(:campaign, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{campaign: campaign} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(campaign, %{location_id: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated campaign on success", %{campaign: campaign} do
      params = %{
        campaign_name: "Updated Campaign"
      }

      assert {:ok, %Campaign{} = updated} = Query.update(campaign, params, Repo)
      assert updated.id == campaign.id
      assert updated.campaign_name == params.campaign_name

      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, campaign: insert(:campaign, %{location_id: context.location.id})}
    end

    test "returns the deleted campaign on success", %{campaign: campaign} do
      assert [active] = Query.get_by_location_id(campaign.location_id, Repo)
      assert active.id == campaign.id

      assert {:ok, %Campaign{} = deleted} = Query.delete(campaign, Repo)
      assert deleted.id == campaign.id
      assert deleted.deleted_at

      assert [] = Query.get_by_location_id(campaign.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%Campaign{id: UUID.uuid4()}, Repo)
    end
  end
end
