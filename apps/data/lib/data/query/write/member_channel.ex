defmodule Data.Query.WriteOnly.MemberChannel do
  @moduledoc false

  alias Data.Schema.MemberChannel
  alias Data.ReadOnly.Repo

  def write(params) do
    %MemberChannel{}
    |> MemberChannel.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> MemberChannel.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
