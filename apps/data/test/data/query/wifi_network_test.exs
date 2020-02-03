defmodule Data.Query.WifiNetworkTest do
  @moduledoc """
  Tests for the Wifi Network Query module
  """
  use Data.DataCase

  alias Data.Query.WifiNetwork, as: Query
  alias Data.Schema.WifiNetwork

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location, team: team}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns wifi network with a valid id", %{location: location} do
      wifi_network = insert(:wifi_network, %{location_id: location.id, network_name: "Fitness1"})

      assert found = Query.get(wifi_network.id, Repo)
      assert "Fitness1" = found.network_name
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns wifi networks for a location id", %{location: location, team: team} do
      location2 = insert(:location, %{team_id: team.id})

      wifi_network = insert(:wifi_network, %{location_id: location.id, network_name: "Fitness1"})
      _ = insert(:wifi_network, %{location_id: location2.id, network_name: "Fitness2"})

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert wifi_network.id == found.id
      assert "Fitness1" = found.network_name
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created wifi network on success", %{location: location} do
      network_name = Faker.Company.name()

      params = %{
        location_id: location.id,
        network_name: network_name,
        network_pword: Faker.Company.buzzword()
      }

      assert {:ok, %WifiNetwork{} = new_record} = Query.create(params, Repo)
      assert network_name == new_record.network_name
      refute new_record.deleted_at
    end
  end

  describe "update/1" do
    setup context do
      {:ok, wifi_network: insert(:wifi_network, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{wifi_network: wifi_network} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(wifi_network, %{location_id: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated wifi network on success", %{wifi_network: wifi_network} do
      params = %{
        network_name: Faker.Company.name(),
        network_pword: Faker.Company.buzzword()
      }

      assert {:ok, %WifiNetwork{} = updated} = Query.update(wifi_network, params, Repo)
      assert updated.id == wifi_network.id

      assert params.network_name == updated.network_name
      assert params.network_pword == updated.network_pword
      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup context do
      {:ok, wifi_network: insert(:wifi_network, %{location_id: context.location.id})}
    end

    test "returns the deleted wifi network on success", %{wifi_network: wifi_network} do
      assert [active] = Query.get_by_location_id(wifi_network.location_id, Repo)
      assert active.id == wifi_network.id

      assert {:ok, %WifiNetwork{} = deleted} = Query.delete(wifi_network, Repo)
      assert deleted.id == wifi_network.id
      assert deleted.deleted_at

      assert [] = Query.get_by_location_id(wifi_network.location_id, Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%WifiNetwork{id: UUID.uuid4()}, Repo)
    end
  end
end
