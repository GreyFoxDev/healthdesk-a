defmodule Data.Query.WriteOnly.Disposition do
  @moduledoc false

  alias Data.Schema.Disposition
  alias Data.WriteOnly.Repo

  def write(params) do
    %Disposition{}
    |> Disposition.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> Disposition.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
