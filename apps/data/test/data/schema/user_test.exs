defmodule Data.Schema.UserTest do
  use ExUnit.Case

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Schema.User

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = User.changeset(%User{}, %{})

    assert errors == [
             phone_number: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} = User.changeset(%User{}, %{phone_number: phone_number()})
  end
end
