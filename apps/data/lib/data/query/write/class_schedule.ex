defmodule Data.Query.WriteOnly.ClassSchedule do
  @moduledoc false

  alias Data.Schema.ClassSchedule
  alias Data.WriteOnly.Repo

  def write(params) do
    %ClassSchedule{}
    |> ClassSchedule.changeset(params)
    |> Repo.insert_or_update!()
  end

  def delete(%{id: id} = params) do
    Repo.delete(params)
  end
end
