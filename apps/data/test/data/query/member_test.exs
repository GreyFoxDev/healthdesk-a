defmodule Data.Query.MemberTest do
  @moduledoc """
  Tests for the Member Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.Member, as: Query
  alias Data.Schema.Member

  setup do
    {:ok, team: insert(:team, %{team_name: "Your Fitness Gym"})}
  end

  describe "all/0" do
    test "returns an empty list when no teams are present" do
      assert [] = Query.all(Repo)
    end

    test "returns active teams", %{team: team} do
      insert_list(3, :member, %{team_id: team.id})
      deleted = insert(:member, %{team_id: team.id, deleted_at: DateTime.utc_now()})
      members = Query.all(Repo)

      assert 3 = Enum.count(members)
      refute Enum.any?(members, &(&1.id == deleted.id))
    end
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns member with a valid id", %{team: team} do
      phone_number = phone_number()
      member = insert(:member, %{phone_number: phone_number, team_id: team.id})

      assert member == Query.get(member.id, Repo)
      assert phone_number == member.phone_number
    end
  end

  describe "get_by_phone/1" do
    setup context do
      insert_list(3, :member, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      refute Query.get_by_phone(phone_number(), Repo)
    end

    test "returns a member using the phone number", %{team: team} do
      phone = phone_number()
      _ = insert(:member, %{phone_number: phone, team_id: team.id})

      assert %Member{} = found = Query.get_by_phone(phone, Repo)
      assert found.team_id == team.id
      assert phone_number = found.phone_number
    end
  end

  describe "get_by_team_id/1" do
    setup context do
      insert_list(3, :member, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      assert [] = Query.get_by_team_id(UUID.uuid4(), Repo)
    end

    test "returns a member using the team id", %{team: team} do
      phone_number = phone_number()
      team2 = insert(:team)
      _ = insert(:member, %{phone_number: phone_number, team_id: team2.id})

      # There should be 3 from the setup
      assert 3 = Query.get_by_team_id(team.id, Repo) |> Enum.count()
      # There should be 1 that was inserted above
      assert [found] = Query.get_by_team_id(team2.id, Repo)
      assert phone_number = found.phone_number
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               phone_number: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created member on success" do
      team = insert(:team)
      phone_number = phone_number()

      params = %{
        first_name: "Jane",
        last_name: "Dobbs",
        phone_number: phone_number,
        team_id: team.id
      }

      assert {:ok, %Member{} = member} = Query.create(params, Repo)
      assert phone_number == member.phone_number
    end
  end

  describe "update/1" do
    setup do
      team = insert(:team)
      {:ok, member: insert(:member, %{team_id: team.id, phone_number: phone_number()})}
    end

    test "returns error if the required fields are not set", %{member: member} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(member, %{phone_number: nil, team_id: nil})

      assert errors == [
               phone_number: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated member on success", %{member: member} do
      params = %{
        first_name: "Jane (edit)",
        last_name: "Dobbs (edit)",
        email: "jane@dobbs.com"
      }

      assert {:ok, %Member{} = updated} = Query.update(member, params, Repo)
      assert updated.id == member.id
      assert updated.first_name == params.first_name
      assert updated.last_name == params.last_name

      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup do
      team = insert(:team)
      {:ok, member: insert(:member, %{team_id: team.id})}
    end

    test "returns the deleted member on success", %{member: member} do
      assert [active] = Query.all(Repo)
      assert active.id == member.id

      assert {:ok, %Member{} = deleted} = Query.delete(member, Repo)
      assert deleted.id == member.id
      assert deleted.deleted_at

      assert [] == Query.all(Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%Member{id: UUID.uuid4()}, Repo)
    end
  end
end
