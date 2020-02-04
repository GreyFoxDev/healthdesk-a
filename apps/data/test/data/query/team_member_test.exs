defmodule Data.Query.TeamMemberTest do
  @moduledoc """
  Tests for the Team Member Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.TeamMember, as: Query
  alias Data.Schema.TeamMember

  setup do
    team = insert(:team, %{team_name: "Your Fitness Gym"})
    location = insert(:location, %{team_id: team.id})
    user = insert(:user, %{phone_number: phone_number()})

    {:ok, team: team, location: location, user: user}
  end

  describe "all/0" do
    test "returns an empty list when no teams are present" do
      assert [] = Query.all(Repo)
    end

    test "returns active team members", %{team: team, location: location} do
      Enum.each(1..3, fn _ ->
        user = insert(:user)
        insert(:team_member, %{team_id: team.id, location_id: location.id, user_id: user.id})
      end)

      user = insert(:user, %{deleted_at: DateTime.utc_now()})

      deleted =
        insert(
          :team_member,
          %{team_id: team.id, location_id: location.id, user_id: user.id}
        )

      team_members = Query.all(Repo)

      assert 3 = Enum.count(team_members)
      refute Enum.any?(team_members, &(&1.user_id == deleted.user_id))
    end
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns team member with a valid id", %{team: team, location: location} do
      user = insert(:user)

      team_member =
        insert(
          :team_member,
          %{location_id: location.id, team_id: team.id, user_id: user.id}
        )

      assert found = Query.get(team_member.id, Repo)
      assert team.id == found.team_id
      assert location.id == found.location_id
      assert user.first_name == found.user.first_name
    end
  end

  describe "get_by_team_id/1" do
    setup context do
      Enum.each(1..3, fn _ ->
        user = insert(:user)

        insert(
          :team_member,
          %{team_id: context.team.id, location_id: context.location.id, user_id: user.id}
        )
      end)

      {:ok, context}
    end

    test "returns nil if record is not found" do
      assert [] = Query.get_by_team_id(UUID.uuid4(), Repo)
    end

    test "returns a location using the team id", %{team: team} do
      team2 = insert(:team)
      location2 = insert(:location, %{team_id: team2.id})
      user = insert(:user)
      _ = insert(:team_member, %{team_id: team2.id, location_id: location2.id, user_id: user.id})

      # There should be 3 from the setup
      assert 3 = Query.get_by_team_id(team.id, Repo) |> Enum.count()
      # There should be 1 that was inserted above
      assert [found] = Query.get_by_team_id(team2.id, Repo)
      assert found.team_id == team2.id
      assert found.location_id == location2.id

      # User should be preloaded
      assert user.first_name == found.user.first_name
    end
  end

  describe "get_by_location_id/1" do
    setup context do
      Enum.each(1..3, fn _ ->
        user = insert(:user)

        insert(
          :team_member,
          %{team_id: context.team.id, location_id: context.location.id, user_id: user.id}
        )
      end)

      {:ok, context}
    end

    test "returns an empty list if record is not found" do
      assert [] = Query.get_by_team_id(UUID.uuid4(), Repo)
    end

    test "returns a team member using the location id", %{location: location} do
      team2 = insert(:team)
      location2 = insert(:location, %{team_id: team2.id})
      user = insert(:user)
      _ = insert(:team_member, %{team_id: team2.id, location_id: location2.id, user_id: user.id})

      # There should be 3 from the setup
      assert 3 = Query.get_by_location_id(location.id, Repo) |> Enum.count()
      # There should be 1 that was inserted above
      assert [found] = Query.get_by_team_id(team2.id, Repo)
      assert found.team_id == team2.id
      assert found.location_id == location2.id

      # User should be preloaded
      assert user.first_name == found.user.first_name
    end
  end

  describe "get_available_by_location/1" do
    setup context do
      user1 =
        insert(:user, %{
          use_sms: true,
          use_do_not_disturb: true,
          start_do_not_disturb: "18:00",
          end_do_not_disturb: "07:00"
        })

      user2 =
        insert(:user, %{
          use_sms: true,
          use_do_not_disturb: true,
          start_do_not_disturb: "22:00",
          end_do_not_disturb: "09:00"
        })

      user3 = insert(:user, %{use_sms: true, use_do_not_disturb: false})

      insert(
        :team_member,
        %{team_id: context.team.id, location_id: context.location.id, user_id: user1.id}
      )

      insert(
        :team_member,
        %{team_id: context.team.id, location_id: context.location.id, user_id: user2.id}
      )

      insert(
        :team_member,
        %{team_id: context.team.id, location_id: context.location.id, user_id: user3.id}
      )

      {:ok, [user: user2, location: context.location]}
    end

    test "during normal hours all are returned", %{location: location} do
      assert 3 = Query.get_available_by_location(location, "10:00", Repo) |> Enum.count()
    end

    test "return only the 2 active team members contact information", %{
      location: location,
      user: user
    } do
      team_members = Query.get_available_by_location(location, "19:00", Repo)
      assert 2 = Enum.count(team_members)
      assert user.email in Enum.map(team_members, & &1.email)
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]},
               user_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created location on success", %{team: team, location: location} do
      user = insert(:user)

      params = %{
        location_id: location.id,
        team_id: team.id,
        user_id: user.id
      }

      assert {:ok, %TeamMember{} = team_member} = Query.create(params, Repo)
      assert user.id == team_member.user_id
      assert team.id == team_member.team_id
      assert location.id == team_member.location_id
    end
  end

  describe "update/1" do
    setup context do
      user = insert(:user)

      {:ok,
       team_member:
         insert(
           :team_member,
           %{team_id: context.team.id, location_id: context.location.id, user_id: user.id}
         )}
    end

    test "returns error if the required fields are not set", %{team_member: team_member} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(
                 team_member,
                 %{location_id: nil, team_id: nil, user_id: nil}
               )

      assert errors == [
               location_id: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]},
               user_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated team member on success", %{team_member: team_member} do
      params = %{
        deleted_at: DateTime.utc_now()
      }

      assert {:ok, %TeamMember{} = updated} = Query.update(team_member, params, Repo)
      assert updated.id == team_member.id
      assert updated.deleted_at
    end
  end

  describe "delete/1" do
    setup do
      team = insert(:team, %{team_name: "Another Team"})
      location = insert(:location, %{team_id: team.id})
      user = insert(:user, %{phone_number: phone_number()})

      {:ok,
       team_member:
         insert(
           :team_member,
           %{team_id: team.id, location_id: location.id, user_id: user.id}
         )}
    end

    test "returns the deleted team member on success", %{team_member: team_member} do
      assert [active] = Query.all(Repo)
      assert active.id == team_member.id

      assert {:ok, %TeamMember{} = deleted} = Query.delete(team_member, Repo)
      assert deleted.id == team_member.id
      assert deleted.deleted_at

      assert [] == Query.all(Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%TeamMember{id: UUID.uuid4()}, Repo)
    end
  end

  describe "associate_locations/2" do
    test "returns a list of team member locations", %{team: team, location: location} do
      user = insert(:user)

      team_member =
        insert(
          :team_member,
          %{location_id: location.id, team_id: team.id, user_id: user.id}
        )

      team_member = Query.get(team_member.id, Repo)
      assert [] = team_member.team_member_locations

      location_ids =
        3
        |> insert_list(:location, %{team_id: team.id})
        |> Enum.map(& &1.id)

      assert team_member.id
             |> Query.associate_locations(location_ids)
             |> is_list()
    end
  end
end
