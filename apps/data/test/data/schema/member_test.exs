defmodule Data.Schema.MemberTest do
  use ExUnit.Case

  alias Data.Schema.Member

  import Data.TestHelper, only: [phone_number: 0]

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = Member.changeset(%Member{}, %{})

    assert errors == [
             phone_number: {"can't be blank", [validation: :required]},
             team_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             Member.changeset(%Member{}, %{
               team_id: UUID.uuid4(),
               phone_number: phone_number()
             })
  end
end
