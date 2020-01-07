defmodule Data.Query.ReadOnly.ConversationDisposition do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.ConversationDisposition
  alias Data.ReadOnly.Repo

  def all do
    Repo.all(ConversationDisposition)
  end

  def all(team_id) do
    from(t in ConversationDisposition,
      where: t.team_id == ^team_id
    )
    |> Repo.all()
  end

  def get(id),
    do: Repo.get(ConversationDisposition, id)

end
