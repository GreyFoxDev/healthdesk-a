defmodule Data.Query.WriteOnly.Team do
  @moduledoc false

  alias Data.Schema.Team
  alias Data.WriteOnly.Repo

  def write(params) do
    %Team{}
    |> Team.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> Team.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
