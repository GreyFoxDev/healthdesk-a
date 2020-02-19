defmodule Data.Schema.LocationTest do
  use ExUnit.Case

  alias Data.Schema.Location

  import Data.TestHelper, only: [phone_number: 0]

  @uuid_regexp ~r/[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}/

  @test_data %{
    location_name: "Location 1",
    phone_number: phone_number(),
    team_id: UUID.uuid4()
  }

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, %{})

    assert errors == [
             location_name: {"can't be blank", [validation: :required]},
             phone_number: {"can't be blank", [validation: :required]},
             team_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} = Location.changeset(%Location{}, @test_data)
  end

  describe "api key generation" do
    test "generates an api key for nil value" do
      assert %{valid?: true, changes: %{api_key: key}} =
               Location.changeset(%Location{}, @test_data)

      assert String.match?(key, @uuid_regexp)
    end

    test "generates an api key for empty string value" do
      params = Map.put(@test_data, :api_key, "")

      assert %{valid?: true, changes: %{api_key: key}} =
               Location.changeset(%Location{api_key: ""}, params)

      assert String.match?(key, @uuid_regexp)
    end

    test "does not generate an api key" do
      api_key = UUID.uuid4()
      params = Map.put(@test_data, :api_key, api_key)

      assert %{valid?: true, changes: %{api_key: ^api_key}} =
               Location.changeset(%Location{}, params)
    end
  end

  describe "validate character lengths" do
    test "location_name <= 250" do
      long_name = Enum.join(0..251)
      params = Map.put(@test_data, :location_name, long_name)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               location_name:
                 {"should be at most %{count} character(s)",
                  [count: 250, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "phone_number <= 50" do
      long_phone = Enum.join(0..51)
      params = Map.put(@test_data, :phone_number, long_phone)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               phone_number:
                 {"should be at most %{count} character(s)",
                  [count: 50, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "address_1 <= 250" do
      long_address = Enum.join(0..251)
      params = Map.put(@test_data, :address_1, long_address)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               address_1:
                 {"should be at most %{count} character(s)",
                  [count: 250, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "address_2 <= 250" do
      long_address = Enum.join(0..251)
      params = Map.put(@test_data, :address_2, long_address)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               address_2:
                 {"should be at most %{count} character(s)",
                  [count: 250, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "city <= 100" do
      long_city = Enum.join(0..100)
      params = Map.put(@test_data, :city, long_city)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               city:
                 {"should be at most %{count} character(s)",
                  [count: 100, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "state <= 2" do
      long_state = "Colorado"
      params = Map.put(@test_data, :state, long_state)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               state:
                 {"should be at most %{count} character(s)",
                  [count: 2, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "postal_code <= 20" do
      long_postal_code = Enum.join(0..21)
      params = Map.put(@test_data, :postal_code, long_postal_code)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               postal_code:
                 {"should be at most %{count} character(s)",
                  [count: 20, validation: :length, kind: :max, type: :string]}
             ]
    end

    test "mindbody_location_id <= 20" do
      long_mindbody_location_id = "123456789012345678901"
      params = Map.put(@test_data, :mindbody_location_id, long_mindbody_location_id)

      assert %{valid?: false, errors: errors} = Location.changeset(%Location{}, params)

      assert errors == [
               mindbody_location_id:
                 {"should be at most %{count} character(s)",
                  [count: 20, validation: :length, kind: :max, type: :string]}
             ]
    end
  end
end
