defmodule Data.Query.PricingPlanTest do
  @moduledoc """
  Tests for the Wifi Network Query module
  """
  use Data.DataCase

  alias Data.Query.PricingPlan, as: Query
  alias Data.Schema.PricingPlan

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns pricing plan with a valid id", %{location: location} do
      pricing_plan =
        insert(
          :pricing_plan,
          %{location_id: location.id, has_daily: false, has_weekly: true, weekly: "$50 per week"}
        )

      assert found = Query.get(pricing_plan.id, Repo)
      assert found.has_weekly
      assert found.weekly == "$50 per week"
      refute found.has_daily
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns pricing plans for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      pricing_plan = insert(:pricing_plan, %{location_id: location.id})
      _ = insert(:pricing_plan, %{location_id: location2.id})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert pricing_plan.id == found.id
    end
  end

  describe "active_daily_pass/1" do
    test "returns nil if records are not found" do
      refute Query.active_daily_pass(UUID.uuid4(), Repo)
    end

    test "returns nil when there is no daily pricing plan", %{location: location} do
      _ = insert(:pricing_plan, %{location_id: location.id, has_daily: false})

      refute Query.active_daily_pass(location.id, Repo)
    end

    test "returns pass price when there's a daily pricing plan", %{location: location} do
      _ = insert(:pricing_plan, %{location_id: location.id, has_daily: true, daily: "$5 per day"})

      assert %{pass_price: "$5 per day"} = Query.active_daily_pass(location.id, Repo)
    end
  end

  describe "active_weekly_pass/1" do
    test "returns nil if records are not found" do
      refute Query.active_weekly_pass(UUID.uuid4(), Repo)
    end

    test "returns nil when there is no weekly pricing plan", %{location: location} do
      _ = insert(:pricing_plan, %{location_id: location.id, has_weekly: false})

      refute Query.active_weekly_pass(location.id, Repo)
    end

    test "returns pass price when there's a weekly pricing plan", %{location: location} do
      _ =
        insert(:pricing_plan, %{
          location_id: location.id,
          has_weekly: true,
          weekly: "$25 per week"
        })

      assert %{pass_price: "$25 per week"} = Query.active_weekly_pass(location.id, Repo)
    end
  end

  describe "active_monthly_pass/1" do
    test "returns nil if records are not found" do
      refute Query.active_monthly_pass(UUID.uuid4(), Repo)
    end

    test "returns nil when there is no monthly pricing plan", %{location: location} do
      _ = insert(:pricing_plan, %{location_id: location.id, has_monthly: false})

      refute Query.active_monthly_pass(location.id, Repo)
    end

    test "returns pass price when there's a monthly pricing plan", %{location: location} do
      _ =
        insert(:pricing_plan, %{
          location_id: location.id,
          has_monthly: true,
          monthly: "$35 per month"
        })

      assert %{pass_price: "$35 per month"} = Query.active_monthly_pass(location.id, Repo)
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created pricing plan on success", %{location: location} do
      params = %{
        location_id: location.id,
        has_daily: false,
        has_weekly: true,
        weekly: "$50 per week"
      }

      assert {:ok, %PricingPlan{} = new_record} = Query.create(params, Repo)
      assert new_record.has_weekly
      assert new_record.weekly == "$50 per week"
      refute new_record.has_daily
      refute new_record.deleted_at
    end
  end

  describe "update/1" do
    setup context do
      {:ok, pricing_plan: insert(:pricing_plan, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{pricing_plan: pricing_plan} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(pricing_plan, %{location_id: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated pricing plan on success", %{pricing_plan: pricing_plan} do
      params = %{
        has_daily: false,
        has_weekly: true,
        weekly: "$50 per week"
      }

      assert {:ok, %PricingPlan{} = updated} = Query.update(pricing_plan, params, Repo)
      assert updated.id == pricing_plan.id

      assert updated.has_weekly
      assert updated.weekly == "$50 per week"
      assert updated.weekly != pricing_plan.weekly
      refute updated.has_daily
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, pricing_plan: insert(:pricing_plan, %{location_id: context.location.id})}
    end

    test "returns the deleted pricing plan on success", %{pricing_plan: pricing_plan} do
      assert [active] = Query.get_by_location_id(pricing_plan.location_id, Repo)
      assert active.id == pricing_plan.id

      assert {:ok, %PricingPlan{} = deleted} = Query.delete(pricing_plan, Repo)
      assert deleted.id == pricing_plan.id
      assert deleted.deleted_at

      assert [] = Query.get_by_location_id(pricing_plan.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%PricingPlan{id: UUID.uuid4()}, Repo)
    end
  end
end
