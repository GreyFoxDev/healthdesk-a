defmodule Data.Query.WriteOnly.Location do
  @moduledoc false

  alias Data.Schema.Location
  alias Data.ReadOnly.Repo

  def write(params) do
    %Location{}
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
