defmodule Data.Schema.ConversationMessageTest do
  use ExUnit.Case

  alias Data.Schema.ConversationMessage

  import Data.TestHelper, only: [phone_number: 0]

  test "validate required fields" do
    assert %{valid?: false, errors: errors} =
             ConversationMessage.changeset(%ConversationMessage{}, %{})

    assert errors == [
             conversation_id: {"can't be blank", [validation: :required]},
             phone_number: {"can't be blank", [validation: :required]},
             message: {"can't be blank", [validation: :required]},
             sent_at: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             ConversationMessage.changeset(%ConversationMessage{}, %{
               conversation_id: UUID.uuid4(),
               phone_number: phone_number(),
               message: "Hello",
               sent_at: DateTime.utc_now()
             })
  end
end
