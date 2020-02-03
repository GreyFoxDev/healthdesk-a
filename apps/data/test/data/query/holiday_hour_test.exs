defmodule Data.Query.HolidayHourTest do
  @moduledoc """
  Tests for the Holiday Hour Query module
  """
  use Data.DataCase

  alias Data.Query.HolidayHour, as: Query
  alias Data.Schema.HolidayHour

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns holiday hour with a valid id", %{location: location} do
      holiday_hour = insert(:holiday_hour, %{location_id: location.id, holiday_name: "Christmas"})

      assert found = Query.get(holiday_hour.id, Repo)
      assert "Christmas" = found.holiday_name
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns holiday hours for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      holiday_hour = insert(:holiday_hour, %{location_id: location.id, holiday_name: "Christmas"})
      _ = insert(:holiday_hour, %{location_id: location2.id, holiday_name: "Other Holiday"})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert holiday_hour.id == found.id
      assert found.holiday_name == "Christmas"
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created holiday hour on success", %{location: location} do
      params = %{
        location_id: location.id,
        holiday_name: "Christmas"
      }

      assert {:ok, %HolidayHour{} = new_record} = Query.create(params, Repo)
      assert "Christmas" == new_record.holiday_name
      refute new_record.deleted_at
    end
  end

  describe "update/1" do
    setup context do
      {:ok, holiday_hour: insert(:holiday_hour, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{holiday_hour: holiday_hour} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(holiday_hour, %{location_id: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated holiday hour on success", %{holiday_hour: holiday_hour} do
      params = %{
        open_at: "10:00 AM",
        close_at: "11:45 AM"
      }

      assert {:ok, %HolidayHour{} = updated} = Query.update(holiday_hour, params, Repo)
      assert updated.id == holiday_hour.id
      assert updated.holiday_name == holiday_hour.holiday_name

      assert params.open_at == updated.open_at
      assert params.close_at == updated.close_at
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, holiday_hour: insert(:holiday_hour, %{location_id: context.location.id})}
    end

    test "returns the deleted holiday hour on success", %{holiday_hour: holiday_hour} do
      assert [active] = Query.get_by_location_id(holiday_hour.location_id, Repo)
      assert active.id == holiday_hour.id

      assert {:ok, %HolidayHour{} = deleted} = Query.delete(holiday_hour, Repo)
      assert deleted.id == holiday_hour.id
      assert deleted.deleted_at

      assert [] = Query.get_by_location_id(holiday_hour.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%HolidayHour{id: UUID.uuid4()}, Repo)
    end
  end
end
