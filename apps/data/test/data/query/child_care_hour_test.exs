defmodule Data.Query.ChildCareHourTest do
  @moduledoc """
  Tests for the Child Care Hour Query module
  """
  use Data.DataCase

  alias Data.Query.ChildCareHour, as: Query
  alias Data.Schema.ChildCareHour

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns child care hour with a valid id", %{location: location} do
      child_care_hour =
        insert(:child_care_hour, %{location_id: location.id, day_of_week: "Saturday"})

      assert found = Query.get(child_care_hour.id, Repo)
      assert "Saturday" = found.day_of_week
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns child care hours for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      child_care_hour =
        insert(:child_care_hour, %{location_id: location.id, day_of_week: "Saturday"})

      _ = insert(:child_care_hour, %{location_id: location2.id, day_of_week: "Tuesday"})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert child_care_hour.id == found.id
      assert "Saturday" = found.day_of_week
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created child care hour on success", %{location: location} do
      params = %{
        location_id: location.id,
        day_of_week: "Monday",
        active: true
      }

      assert {:ok, %ChildCareHour{} = new_record} = Query.create(params, Repo)
      assert "Monday" == new_record.day_of_week
      assert new_record.active
    end
  end

  describe "update/1" do
    setup context do
      {:ok, child_care_hour: insert(:child_care_hour, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{child_care_hour: child_care_hour} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(child_care_hour, %{location_id: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated child care hour on success", %{child_care_hour: child_care_hour} do
      params = %{
        morning_open_at: "10:00 AM",
        morning_close_at: "11:45 AM",
        afternoon_open_at: "1:30 PM",
        afternoon_close_at: "4:30 PM",
        active: false
      }

      assert {:ok, %ChildCareHour{} = updated} = Query.update(child_care_hour, params, Repo)
      assert updated.id == child_care_hour.id
      assert updated.day_of_week == child_care_hour.day_of_week
      assert child_care_hour.active

      assert params.morning_open_at == updated.morning_open_at
      assert params.morning_close_at == updated.morning_close_at
      assert params.afternoon_open_at == updated.afternoon_open_at
      assert params.afternoon_close_at == updated.afternoon_close_at
      refute updated.active
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, child_care_hour: insert(:child_care_hour, %{location_id: context.location.id})}
    end

    test "returns the deleted child care hour on success", %{child_care_hour: child_care_hour} do
      assert [active] = Query.get_by_location_id(child_care_hour.location_id, Repo)
      assert active.id == child_care_hour.id

      assert {:ok, %ChildCareHour{} = deleted} = Query.delete(child_care_hour, Repo)
      assert deleted.id == child_care_hour.id
      assert deleted.deleted_at

      assert [] = Query.get_by_location_id(child_care_hour.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%ChildCareHour{id: UUID.uuid4()}, Repo)
    end
  end
end
