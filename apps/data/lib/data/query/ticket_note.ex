defmodule Data.Query.TicketNote do
  @moduledoc """
  Module for the TicketNote queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.TicketNote
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a ticket by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: TicketNote.t() | nil
  def get(id, repo \\ Read) do
    from(t in TicketNote,
      where: t.id == ^id,
      preload: [:user]
    )
    |> repo.one()
  end

  @doc """
  Creates a new TicketNote
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, TicketNote.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %TicketNote{}
    |> TicketNote.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
