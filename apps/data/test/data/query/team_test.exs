defmodule Data.Query.TeamTest do
  @moduledoc """
  Tests for the Team Query module
  """
  use Data.DataCase

  alias Data.Query.Team, as: Query
  alias Data.Schema.Team

  describe "all/0" do
    test "returns an empty list when no teams are present" do
      assert [] = Query.all(Repo)
    end

    test "returns active teams" do
      insert_list(3, :team)
      deleted = insert(:team, %{deleted_at: DateTime.utc_now()})
      teams = Query.all(Repo)

      assert 3 = Enum.count(teams)
      refute Enum.any?(teams, &(&1.id == deleted.id))
    end
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns team with a valid id" do
      team_name = Faker.Company.name()
      team = insert(:team, %{team_name: team_name})

      assert found = Query.get(team.id, Repo)
      assert team_name == found.team_name
      assert [] = found.locations
      assert [] = found.team_members
    end

    test "returns team with locations" do
      team = insert(:team)
      location = insert(:location, %{team_id: team.id})

      assert found = Query.get(team.id, Repo)
      assert [location] == found.locations
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               team_name: {"can't be blank", [validation: :required]},
               website: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created team on success" do
      team_name = Faker.Company.name()

      params = %{
        team_name: team_name,
        website: "#{String.replace(team_name, " ", "-")}.com"
      }

      assert {:ok, %Team{} = team} = Query.create(params, Repo)
      assert team_name == team.team_name
    end
  end

  describe "update/1" do
    setup do
      {:ok, team: insert(:team)}
    end

    test "returns error if the required fields are not set", %{team: team} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(team, %{website: nil, team_name: nil})

      assert errors == [
               team_name: {"can't be blank", [validation: :required]},
               website: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated team on success", %{team: team} do
      params = %{
        team_member_count: 10,
        twilio_flow_id: "FO12345678910"
      }

      assert {:ok, %Team{} = updated} = Query.update(team, params, Repo)
      assert updated.id == team.id
      assert updated.team_name == team.team_name
      assert updated.team_member_count == 10
      assert updated.twilio_flow_id == "FO12345678910"
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup do
      {:ok, team: insert(:team)}
    end

    test "returns the deleted team on success", %{team: team} do
      assert [active] = Query.all(Repo)
      assert active.id == team.id

      assert {:ok, %Team{} = deleted} = Query.delete(team, Repo)
      assert deleted.id == team.id
      assert deleted.deleted_at

      assert [] == Query.all(Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%Team{id: UUID.uuid4()}, Repo)
    end
  end
end
