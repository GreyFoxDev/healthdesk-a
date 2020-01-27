defmodule Data.Query.ClassScheduleTest do
  @moduledoc """
  Tests for the Child Care Hour Query module
  """
  use Data.DataCase

  alias Data.Query.ClassSchedule, as: Query
  alias Data.Schema.ClassSchedule

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns team with a valid id", %{location: location} do
      class_schedule = insert(:class_schedule, %{location_id: location.id})

      assert found = Query.get(class_schedule.id, Repo)
      assert found.id == class_schedule.id
      assert found.class_category == class_schedule.class_category
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns class schedule for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      class_schedule = insert(:class_schedule, %{location_id: location.id, date: ~D[2020-03-04]})
      _ = insert(:class_schedule, %{location_id: location2.id, date: ~D[2020-03-05]})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert class_schedule.id == found.id
      assert ~D[2020-03-04] == found.date
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created team on success", %{location: location} do
      params = %{
        location_id: location.id,
        date: "3/4/2020",
        start_time: "8:00 AM",
        end_time: "9:00 AM"
      }

      assert {:ok, %ClassSchedule{} = new_record} = Query.create(params, Repo)
      assert new_record.date == ~D[2020-03-04]
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, class_schedule: insert(:class_schedule, %{location_id: context.location.id})}
    end

    test "returns the deleted class schedule on success", %{class_schedule: class_schedule} do
      assert [active] = Query.get_by_location_id(class_schedule.location_id, Repo)
      assert active.id == class_schedule.id

      assert {:ok, %ClassSchedule{} = deleted} = Query.delete(class_schedule, Repo)
      assert deleted.id == class_schedule.id

      assert [] = Query.get_by_location_id(class_schedule.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%ClassSchedule{id: UUID.uuid4()}, Repo)
    end
  end
end
