defmodule Data.Schema.MemberChannelTest do
  use ExUnit.Case

  alias Data.Schema.MemberChannel

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = MemberChannel.changeset(%MemberChannel{}, %{})

    assert errors == [
             channel_id: {"can't be blank", [validation: :required]},
             member_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             MemberChannel.changeset(%MemberChannel{}, %{
               channel_id: "WC123456",
               member_id: UUID.uuid4()
             })
  end
end
