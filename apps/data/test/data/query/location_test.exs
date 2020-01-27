defmodule Data.Query.LocationTest do
  @moduledoc """
  Tests for the Location Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.Location, as: Query
  alias Data.Schema.Location

  setup do
    {:ok, team: insert(:team, %{team_name: "Your Fitness Gym"})}
  end

  describe "all/0" do
    test "returns an empty list when no teams are present" do
      assert [] = Query.all(Repo)
    end

    test "returns active locations", %{team: team} do
      insert_list(3, :location, %{team_id: team.id})
      deleted = insert(:location, %{team_id: team.id, deleted_at: DateTime.utc_now()})
      locations = Query.all(Repo)

      assert 3 = Enum.count(locations)
      refute Enum.any?(locations, &(&1.id == deleted.id))
    end
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns location with a valid id", %{team: team} do
      location_name = Faker.Company.name()
      location = insert(:location, %{location_name: location_name, team_id: team.id})

      assert location == Query.get(location.id, Repo)
      assert location_name == location.location_name
    end
  end

  describe "get_by_phone/1" do
    setup context do
      insert_list(3, :location, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      refute Query.get_by_phone(phone_number(), Repo)
    end

    test "returns a location using the phone number", %{team: team} do
      phone = phone_number()
      location = insert(:location, %{phone_number: phone, team_id: team.id})

      assert %Location{} = found = Query.get_by_phone(phone, Repo)
      assert found.team_id == team.id
      assert found.location_name == location.location_name

      # Team should be preloaded
      assert found.team.team_name == team.team_name
    end
  end

  describe "get_by_team_id/1" do
    setup context do
      insert_list(3, :location, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      assert [] = Query.get_by_team_id(UUID.uuid4(), Repo)
    end

    test "returns a location using the team id", %{team: team} do
      team2 = insert(:team)
      _ = insert(:location, %{team_id: team2.id})

      # There should be 3 from the setup
      assert 3 = Query.get_by_team_id(team.id, Repo) |> Enum.count()
      # There should be 1 that was inserted above
      assert [found] = Query.get_by_team_id(team2.id, Repo)

      # Team should be preloaded
      assert found.team.team_name == team2.team_name
    end
  end

  describe "get_by_api_key/1" do
    setup context do
      insert_list(3, :location, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      refute Query.get_by_api_key(UUID.uuid4(), Repo)
    end

    test "returns a location using the api key", %{team: team} do
      api_key = UUID.uuid4()
      location = insert(:location, %{team_id: team.id, api_key: api_key})

      assert %Location{} = found = Query.get_by_api_key(api_key, Repo)
      assert found.team_id == team.id
      assert found.location_name == location.location_name
    end
  end

  describe "get_by_messenger_id/1" do
    setup context do
      insert_list(3, :location, %{team_id: context.team.id})
      {:ok, context}
    end

    test "returns nil if record is not found" do
      refute Query.get_by_messenger_id(phone_number(), Repo)
    end

    test "returns a location using the messenger id", %{team: team} do
      messenger_id = "123456789"
      location = insert(:location, %{messenger_id: messenger_id, team_id: team.id})

      assert %Location{} = found = Query.get_by_messenger_id(messenger_id, Repo)
      assert found.team_id == team.id
      assert found.location_name == location.location_name

      # Team should be preloaded
      assert found.team.team_name == team.team_name
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_name: {"can't be blank", [validation: :required]},
               phone_number: {"can't be blank", [validation: :required]},
               team_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created location on success" do
      team = insert(:team)
      location_name = Faker.Company.name()

      params = %{
        location_name: location_name,
        phone_number: phone_number(),
        team_id: team.id
      }

      assert {:ok, %Location{} = location} = Query.create(params, Repo)
      assert location_name == location.location_name
    end
  end

  describe "update/1" do
    setup do
      team = insert(:team)
      {:ok, location: insert(:location, %{team_id: team.id})}
    end

    test "returns error if the required fields are not set", %{location: location} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(location, %{phone_number: nil, location_name: nil})

      assert errors == [
               location_name: {"can't be blank", [validation: :required]},
               phone_number: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated location on success", %{location: location} do
      params = %{
        address_1: Faker.Address.street_address(),
        city: Faker.Address.city(),
        state: Faker.Address.state_abbr(),
        postal_code: Faker.Address.postcode(),
        web_greeting: "Hello there!",
        web_handle: "Website Bot",
        web_chat: true,
        timezone: "PST8PDT",
        slack_integration: "http://slack.com",
        messenger_id: "123456"
      }

      assert {:ok, %Location{} = updated} = Query.update(location, params, Repo)
      assert updated.id == location.id
      assert updated.location_name == location.location_name

      assert params.address_1 == updated.address_1
      assert params.city == updated.city
      assert params.state == updated.state
      assert params.postal_code == updated.postal_code
      assert params.web_greeting == updated.web_greeting
      assert params.web_handle == updated.web_handle
      assert params.web_chat == updated.web_chat
      assert params.timezone == updated.timezone
      assert params.slack_integration == updated.slack_integration
      assert params.messenger_id == updated.messenger_id

      assert updated.location_name == location.location_name
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup do
      team = insert(:team)
      {:ok, location: insert(:location, %{team_id: team.id})}
    end

    test "returns the deleted location on success", %{location: location} do
      assert [active] = Query.all(Repo)
      assert active.id == location.id

      assert {:ok, %Location{} = deleted} = Query.delete(location, Repo)
      assert deleted.id == location.id
      assert deleted.deleted_at

      assert [] == Query.all(Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%Location{id: UUID.uuid4()}, Repo)
    end
  end
end
