defmodule Data.Query.DispositionTest do
  @moduledoc """
  Tests for the Disposition Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.Disposition, as: Query
  alias Data.Schema.Disposition

  setup do
    {:ok, team: insert(:team, %{team_name: "Your Fitness Gym"})}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns disposition with a valid id", %{team: team} do
      disposition_name = Faker.Company.name()
      disposition = insert(:disposition, %{disposition_name: disposition_name, team_id: team.id})

      assert disposition == Query.get(disposition.id, Repo)
      assert disposition_name == disposition.disposition_name
    end
  end

  describe "get_by_team_id/1" do
    setup context do
      insert_list(3, :disposition, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      assert [] = Query.get_by_team_id(UUID.uuid4(), Repo)
    end

    test "returns a disposition using the team id", %{team: team} do
      team2 = insert(:team)
      disposition = insert(:disposition, %{team_id: team2.id})

      # There should be 3 from the setup
      assert 3 = Query.get_by_team_id(team.id, Repo) |> Enum.count()
      # There should be 1 that was inserted above
      assert [found] = Query.get_by_team_id(team2.id, Repo)
      assert found.id == disposition.id
    end
  end

  describe "count functions when not found" do
    test "count_all/0 returns an empty list if not found" do
      assert [] = Query.count_all(Repo)
    end

    test "count_by_team_id/1 returns an empty list if not found" do
      assert [] = Query.count_by_team_id(UUID.uuid4(), Repo)
    end

    test "count_by_location_id/1 returns an empty list if not found" do
      assert [] = Query.count_by_location_id(UUID.uuid4(), Repo)
    end

    test "count/1 returns 0 if no records found" do
      assert 0 = Query.count(UUID.uuid4(), Repo)
    end
  end

  describe "count functions with data" do
    setup %{team: team1} do
      team2 = insert(:team)
      location1 = insert(:location, %{team_id: team1.id, phone_number: phone_number()})
      location2 = insert(:location, %{team_id: team2.id, phone_number: phone_number()})
      [team1_disposition | _] = insert_list(3, :disposition, %{team_id: team1.id})
      [team2_disposition | _] = insert_list(3, :disposition, %{team_id: team2.id})

      conversation1 =
        insert(:conversation, %{location_id: location1.id, original_number: phone_number()})

      conversation2 =
        insert(:conversation, %{location_id: location2.id, original_number: phone_number()})

      insert(:conversation_disposition, %{
        conversation_id: conversation1.id,
        disposition_id: team1_disposition.id
      })

      insert(:conversation_disposition, %{
        conversation_id: conversation2.id,
        disposition_id: team2_disposition.id
      })

      {:ok, disposition: team2_disposition, location: location1}
    end

    test "count_all/0 returns a list of maps with disposition name & count" do
      assert counts = Query.count_all(Repo)
      assert Enum.count(counts) == 2

      Enum.each(counts, fn d ->
        assert d.count == 1
      end)
    end

    test "count_by_team_id/1 returns a list of maps with disposition name & count", %{team: team} do
      assert [%{count: count}] = Query.count_by_team_id(team.id, Repo)
      assert count == 1
    end

    test "count_by_location_id/1 returns a list of maps with disposition name & count", %{
      location: location
    } do
      assert [%{count: count}] = Query.count_by_location_id(location.id, Repo)
      assert count == 1
    end

    test "count/1 returns an integer count for a disposition", %{disposition: disposition} do
      assert 1 == Query.count(disposition.id, Repo)
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               disposition_name: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created team on success", %{team: team} do
      disposition_name = "CLOSED: TESTING"

      params = %{
        disposition_name: disposition_name,
        team_id: team.id
      }

      assert {:ok, %Disposition{} = disposition} = Query.create(params, Repo)
      assert disposition_name == disposition.disposition_name
    end
  end

  describe "update/1" do
    setup context do
      {:ok, disposition: insert(:disposition, %{team_id: context.team.id})}
    end

    test "returns error if the required fields are not set", %{disposition: disposition} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(disposition, %{team_id: nil, disposition_name: nil})

      assert errors == [
               disposition_name: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated disposition on success", %{disposition: disposition} do
      params = %{
        disposition_name: "Updated Name"
      }

      assert {:ok, %Disposition{} = updated} = Query.update(disposition, params, Repo)
      assert updated.id == disposition.id
      assert params.disposition_name == updated.disposition_name
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, disposition: insert(:disposition, %{team_id: context.team.id})}
    end

    test "returns the deleted disposition on success", %{disposition: disposition} do
      assert [active] = Query.get_by_team_id(disposition.team_id, Repo)
      assert active.id == disposition.id

      assert {:ok, %Disposition{} = deleted} = Query.delete(disposition, Repo)
      assert deleted.id == disposition.id
      assert deleted.deleted_at

      assert [] == Query.get_by_team_id(disposition.team_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%Disposition{id: UUID.uuid4()}, Repo)
    end
  end
end
