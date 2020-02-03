defmodule Data.Schema.DispositionTest do
  use ExUnit.Case

  alias Data.Schema.Disposition

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = Disposition.changeset(%Disposition{}, %{})

    assert errors == [
             disposition_name: {"can't be blank", [validation: :required]},
             team_id: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             Disposition.changeset(%Disposition{}, %{
               team_id: UUID.uuid4(),
               disposition_name: "Closed: Testing"
             })
  end
end
