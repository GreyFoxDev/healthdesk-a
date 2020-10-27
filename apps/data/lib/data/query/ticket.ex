defmodule Data.Query.Ticket do

  @moduledoc """
  Module for the Ticket queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.Ticket
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write



  @doc """
  Creates a new Ticket
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Ticket.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do

    %Ticket{}
    |> Ticket.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)
      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing Ticket
  """
  @spec update(notification :: Ticket.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Ticket.t()} | {:error, Ecto.Changeset.t()}
  def update(%Ticket{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Ticket.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
