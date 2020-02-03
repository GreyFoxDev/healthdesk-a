defmodule Data.ChangesetHelperTest do
  use ExUnit.Case

  import Ecto.Changeset, only: [cast: 3]
  import Data.ChangesetHelper

  alias Data.Schema.Location

  describe "validate_uuid/2" do
    test "returns an error for invalid format" do
      changeset =
        %Location{}
        |> cast(%{id: "TEST"}, [:id])
        |> validate_uuid(:id)

      assert %{valid?: false, errors: errors} = changeset
      assert errors == [id: {"is not a valid UUID", [validation: :format]}]
    end

    test "returns a valid changeset" do
      valid_id = UUID.uuid4()

      changeset =
        %Location{}
        |> cast(%{id: valid_id}, [:id])
        |> validate_uuid(:id)

      assert %{valid?: true, errors: [], changes: changes} = changeset
      assert %{id: valid_id} == changes
    end
  end
end
