defmodule Data.Query.WriteOnly.OptIn do
  @moduledoc false

  alias Data.Schema.OptIn
  alias Data.ReadOnly.Repo

  def write(params) do
    %OptIn{}
    |> OptIn.changeset(params)
    |> Repo.insert_or_update!()
  end

  def write(original, params) do
    original
    |> OptIn.changeset(params)
    |> Repo.insert_or_update!()
  end
end
