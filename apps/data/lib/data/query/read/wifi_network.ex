defmodule Data.Query.ReadOnly.WifiNetwork do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.WifiNetwork
  alias Data.ReadOnly.Repo

  def all,
    do: Repo.all(WifiNetwork)

  def all(location_id) do
    from(t in WifiNetwork,
      where: is_nil(t.deleted_at),
      where: t.location_id == ^location_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(WifiNetwork, id)
end
