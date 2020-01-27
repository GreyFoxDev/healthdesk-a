defmodule Data.Query.NormalHourTest do
  @moduledoc """
  Tests for the Normal Hour Query module
  """
  use Data.DataCase

  alias Data.Query.NormalHour, as: Query
  alias Data.Schema.NormalHour

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns normal hour with a valid id", %{location: location} do
      normal_hour = insert(:normal_hour, %{location_id: location.id, day_of_week: "Saturday"})

      assert found = Query.get(normal_hour.id, Repo)
      assert "Saturday" = found.day_of_week
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns normal hours for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      normal_hour = insert(:normal_hour, %{location_id: location.id, day_of_week: "Saturday"})
      _ = insert(:normal_hour, %{location_id: location2.id, day_of_week: "Tuesday"})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert normal_hour.id == found.id
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

    test "returns the created normal hour on success", %{location: location} do
      params = %{
        location_id: location.id,
        day_of_week: "Monday"
      }

      assert {:ok, %NormalHour{} = new_record} = Query.create(params, Repo)
      assert "Monday" == new_record.day_of_week
      refute new_record.deleted_at
    end
  end

  describe "update/1" do
    setup context do
      {:ok, normal_hour: insert(:normal_hour, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{normal_hour: normal_hour} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(normal_hour, %{location_id: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated normal hour on success", %{normal_hour: normal_hour} do
      params = %{
        open_at: "10:00 AM",
        close_at: "11:45 AM"
      }

      assert {:ok, %NormalHour{} = updated} = Query.update(normal_hour, params, Repo)
      assert updated.id == normal_hour.id
      assert updated.day_of_week == normal_hour.day_of_week

      assert params.open_at == updated.open_at
      assert params.close_at == updated.close_at
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, normal_hour: insert(:normal_hour, %{location_id: context.location.id})}
    end

    test "returns the deleted normal hour on success", %{normal_hour: normal_hour} do
      assert [active] = Query.get_by_location_id(normal_hour.location_id, Repo)
      assert active.id == normal_hour.id

      assert {:ok, %NormalHour{} = deleted} = Query.delete(normal_hour, Repo)
      assert deleted.id == normal_hour.id
      assert deleted.deleted_at

      assert [] = Query.get_by_location_id(normal_hour.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%NormalHour{id: UUID.uuid4()}, Repo)
    end
  end
end
