defmodule Data.Query.WriteOnly.User do
  @moduledoc false

  alias Data.Schema.User
  alias Data.WriteOnly.Repo

  def write(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: _id} = params) do
    params
    |> Map.put(:deleted_at, DateTime.utc_now())
    |> write()
  end
end
