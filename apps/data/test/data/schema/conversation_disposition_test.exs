defmodule Data.Schema.ConversationDispositionTest do
  use ExUnit.Case

  alias Data.Schema.ConversationDisposition

  test "validate required fields" do
    assert %{valid?: false, errors: errors} =
             ConversationDisposition.changeset(%ConversationDisposition{}, %{})

    assert errors == [
             conversation_id: {"can't be blank", [validation: :required]},
             disposition_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             ConversationDisposition.changeset(%ConversationDisposition{}, %{
               conversation_id: UUID.uuid4(),
               disposition_id: UUID.uuid4()
             })
  end
end
