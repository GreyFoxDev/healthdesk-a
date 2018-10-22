defmodule Data.Query.WriteOnly.WifiNetwork do
  @moduledoc false

  alias Data.Schema.WifiNetwork
  alias Data.ReadOnly.Repo

  def write(params) do
    %WifiNetwork{}
    |> WifiNetwork.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> WifiNetwork.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
