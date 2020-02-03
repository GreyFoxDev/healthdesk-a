defmodule Data.Query.ConversationMessageTest do
  @moduledoc """
  Tests for the Conversation Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.ConversationMessage, as: Query
  alias Data.Schema.ConversationMessage

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    conversation =
      insert(:conversation, %{location_id: location.id, original_number: phone_number()})

    {:ok, conversation: conversation}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns conversation message with a valid id", %{conversation: conversation} do
      conversation_message =
        insert(:conversation_message, %{
          conversation_id: conversation.id,
          phone_number: phone_number(),
          message: "Hello"
        })

      assert found = Query.get(conversation_message.id, Repo)
      assert conversation_message.id == found.id
      assert conversation_message.phone_number == found.phone_number
      assert conversation_message.message == "Hello"
    end
  end

  describe "get_by_conversation_id/1" do
    test "returns empty list if records are not found" do
      assert [] = Query.get_by_conversation_id(UUID.uuid4(), Repo)
    end

    test "returns conversation messages for a conversation id", %{conversation: conversation} do
      conversation_message =
        insert(:conversation_message, %{
          conversation_id: conversation.id,
          phone_number: phone_number(),
          message: "Hello"
        })

      assert [found] = Query.get_by_conversation_id(conversation.id, Repo)
      assert conversation_message.id == found.id
      assert conversation.id == found.conversation_id
      assert "Hello" = found.message
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               conversation_id: {"can't be blank", [validation: :required]},
               phone_number: {"can't be blank", [validation: :required]},
               message: {"can't be blank", [validation: :required]},
               sent_at: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created conversation message on success", %{conversation: conversation} do
      params = %{
        conversation_id: conversation.id,
        phone_number: phone_number(),
        message: "Hello",
        sent_at: DateTime.utc_now()
      }

      assert {:ok, %ConversationMessage{} = new_record} = Query.create(params, Repo)
      assert params.phone_number == new_record.phone_number
      assert "Hello" == new_record.message
      assert conversation.id == new_record.conversation_id
    end
  end
end
