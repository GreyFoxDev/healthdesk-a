defmodule Data.Query.WriteOnly.ChildCareHours do
  @moduledoc false

  alias Data.Schema.ChildCareHour
  alias Data.ReadOnly.Repo

  def write(params) do
    %ChildCareHour{}
    |> ChildCareHour.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> ChildCareHour.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
