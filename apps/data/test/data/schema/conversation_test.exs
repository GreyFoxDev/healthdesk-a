defmodule Data.Schema.ConversationTest do
  use ExUnit.Case

  alias Data.Schema.Conversation

  import Data.TestHelper, only: [phone_number: 0]

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = Conversation.changeset(%Conversation{}, %{})

    assert errors == [
             location_id: {"can't be blank", [validation: :required]},
             original_number: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             Conversation.changeset(%Conversation{}, %{
               location_id: UUID.uuid4(),
               original_number: phone_number()
             })
  end
end
