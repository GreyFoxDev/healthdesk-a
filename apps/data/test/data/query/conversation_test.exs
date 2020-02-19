defmodule Data.Query.ConversationTest do
  @moduledoc """
  Tests for the Conversation Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.Conversation, as: Query
  alias Data.Schema.Conversation

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, location: location}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns conversation with a valid id", %{location: location} do
      conversation =
        insert(:conversation, %{location_id: location.id, original_number: phone_number()})

      conversation_message =
        insert(:conversation_message, %{
          conversation_id: conversation.id,
          phone_number: phone_number(),
          message: "Hello"
        })

      assert found = Query.get(conversation.id, Repo)
      assert conversation.id == found.id
      assert conversation.original_number == found.original_number

      assert [message] = found.conversation_messages
      assert message.id == conversation_message.id
      assert message.message == "Hello"
    end
  end

  describe "get_by_location_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_location_id(UUID.uuid4(), Repo)
    end

    test "returns conversations for a location id", %{location: location} do
      original_number = phone_number()

      conversation =
        insert(:conversation, %{location_id: location.id, original_number: original_number})

      conversation_message =
        insert(:conversation_message, %{
          conversation_id: conversation.id,
          phone_number: phone_number(),
          message: "Hello"
        })

      assert [found] = Query.get_by_location_id(location.id, Repo)
      assert conversation.id == found.id

      assert [message] = found.conversation_messages
      assert message.id == conversation_message.id
      assert message.message == "Hello"
    end
  end

  describe "get_by_phone/2 requires location" do
    test "returns nil if record is not found", %{location: location} do
      refute Query.get_by_phone(phone_number(), location.id, Repo)
    end

    test "returns conversation with a phone & location id", %{location: location} do
      original_number = phone_number()

      conversation =
        insert(:conversation, %{location_id: location.id, original_number: original_number})

      assert found = Query.get_by_phone(original_number, location.id, Repo)
      assert conversation.id == found.id
      assert conversation.original_number == found.original_number
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]},
               original_number: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created conversation on success", %{location: location} do
      params = %{
        location_id: location.id,
        original_number: phone_number(),
        status: "open"
      }

      assert {:ok, %Conversation{} = new_record} = Query.create(params, Repo)
      assert params.original_number == new_record.original_number
      assert "SMS" == new_record.channel_type
      assert "open" == new_record.status
    end

    test "set the channel type to WEB", %{location: location} do
      params = %{
        location_id: location.id,
        original_number: "CH1234566",
        status: "open"
      }

      assert {:ok, %Conversation{} = new_record} = Query.create(params, Repo)
      assert params.original_number == new_record.original_number
      assert "WEB" == new_record.channel_type
      assert "open" == new_record.status
    end

    test "set the channel type to FACEBOOK", %{location: location} do
      params = %{
        location_id: location.id,
        original_number: "messenger:1234566",
        status: "open"
      }

      assert {:ok, %Conversation{} = new_record} = Query.create(params, Repo)
      assert params.original_number == new_record.original_number
      assert "FACEBOOK" == new_record.channel_type
      assert "open" == new_record.status
    end

    test "set the channel type to WEB when value passed in", %{location: location} do
      params = %{
        location_id: location.id,
        original_number: phone_number(),
        channel_type: "WEB",
        status: "open"
      }

      assert {:ok, %Conversation{} = new_record} = Query.create(params, Repo)
      assert params.original_number == new_record.original_number
      assert "WEB" == new_record.channel_type
      assert "open" == new_record.status
    end
  end

  describe "update/1" do
    setup context do
      {:ok, conversation: insert(:conversation, %{location_id: context.location.id})}
    end

    test "returns error if the required fields are not set", %{conversation: conversation} do
      assert {:error, %Ecto.Changeset{errors: errors}} =
               Query.update(conversation, %{location_id: nil, original_number: nil})

      assert errors == [
               location_id: {"can't be blank", [validation: :required]},
               original_number: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the updated conversation on success", %{conversation: conversation} do
      params = %{
        status: "closed"
      }

      assert {:ok, %Conversation{} = updated} = Query.update(conversation, params, Repo)
      assert updated.id == conversation.id
      assert "SMS" == updated.channel_type
      assert "closed" = updated.status
    end
  end
end
