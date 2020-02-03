defmodule Data.Schema.TeamTest do
  use ExUnit.Case

  alias Data.Schema.Team

  @test_data %{
    team_name: "Team 1",
    website: "www.example.com"
  }

  test "validate required fields" do
    assert %{valid?: false, errors: errors} = Team.changeset(%Team{}, %{})

    assert errors == [
             team_name: {"can't be blank", [validation: :required]},
             website: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} = Team.changeset(%Team{}, @test_data)
  end
end
