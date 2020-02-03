defmodule Data.Query.UserTest do
  @moduledoc """
  Tests for the User Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.User, as: Query
  alias Data.Schema.User

  describe "all/0" do
    test "returns an empty list when no teams are present" do
      assert [] = Query.all(Repo)
    end

    test "returns active teams" do
      insert_list(3, :user)
      deleted = insert(:user, %{deleted_at: DateTime.utc_now()})
      users = Query.all(Repo)

      assert 3 = Enum.count(users)
      refute Enum.any?(users, &(&1.id == deleted.id))
    end
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns user with a valid id" do
      first_name = Faker.Name.first_name()
      phone = phone_number()
      user = insert(:user, %{first_name: first_name, phone_number: phone})

      assert %User{} = found = Query.get(user.id, Repo)
      assert first_name == found.first_name
      assert phone == found.phone_number
    end
  end

  describe "get_by_phone/1" do
    setup context do
      insert_list(3, :user)
      {:ok, context}
    end

    test "returns nil if record is not found" do
      refute Query.get_by_phone(phone_number(), Repo)
    end

    test "returns a user using the phone number" do
      phone = phone_number()
      user = insert(:user, %{phone_number: phone})

      assert %User{} = found = Query.get_by_phone(phone, Repo)
      assert found.id == user.id
      assert found.first_name == user.first_name
      assert found.last_name == user.last_name
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               phone_number: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created user on success" do
      phone = phone_number()

      params = %{
        phone_number: phone
      }

      assert {:ok, %User{} = user} = Query.create(params, Repo)
      assert phone == user.phone_number
    end
  end

  describe "update/1" do
    setup do
      {:ok, user: insert(:user, %{phone_number: phone_number()})}
    end

    test "returns error if the required fields are not set", %{user: user} do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.update(user, %{phone_number: nil})

      assert errors == [
               phone_number: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated user on success", %{user: user} do
      params = %{
        first_name: Faker.Name.first_name(),
        last_name: Faker.Name.last_name(),
        role: "location-admin",
        email: Faker.Internet.email()
      }

      assert {:ok, %User{} = updated} = Query.update(user, params, Repo)
      assert updated.id == user.id
      assert updated.phone_number == user.phone_number

      assert params.first_name == updated.first_name
      assert params.last_name == updated.last_name
      assert params.role == updated.role
      assert params.email == updated.email

      refute updated.deleted_at
    end
  end

  describe "delete/1" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "returns the deleted user on success", %{user: user} do
      assert [active] = Query.all(Repo)
      assert active.id == user.id

      assert {:ok, %User{} = deleted} = Query.delete(user, Repo)
      assert deleted.id == user.id
      assert deleted.deleted_at

      assert [] == Query.all(Repo)
    end

    test "returns an error if the record is not found" do
      assert {:error, :no_record_found} = Query.delete(%User{id: UUID.uuid4()}, Repo)
    end
  end
end
