defmodule Data.Query.WriteOnly.TeamMember do
  @moduledoc false

  alias Data.Schema.TeamMember
  alias Data.ReadOnly.Repo

  def write(params) do
    %TeamMember{}
    |> TeamMember.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> TeamMember.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
