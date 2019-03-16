defmodule Data.Commands.Team do
  @moduledoc false

  use Data.Commands, schema: Team

  alias Data.Schema.Team

  def get_team_locations(%{}, team_id) do
    with [%Team{} = team] <- Read.team_with_locations(team_id) do
      {:ok, team}
    else
      [] ->
        {:ok, nil}

      _ ->
        {:error, "Query returned more than one matching record for id #{team_id}"}
    end
  end
end
