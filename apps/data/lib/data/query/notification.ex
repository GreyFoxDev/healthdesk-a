defmodule Data.Query.Notification do
  @moduledoc """
  Module for the Notification queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Notification}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Notification.t() | nil
  def get(id, repo \\ Read) do
    from(c in Notification,
      where: c.id == ^id
    )
    |> repo.one()
  end

  @spec get_by_user(user_id :: binary(), repo :: Ecto.Repo.t()) :: [Notification.t()]
  def get_by_user(user_id, repo \\ Read) do
    from(n in Notification,
      where: n.user_id == ^user_id,
      order_by: [desc: n.inserted_at],
      preload: [:user, :sender, :conversation, :ticket]
    )
    |> repo.all()
  end

  @doc """
  Creates a new Notification
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %Notification{}
    |> Notification.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing Notification
  """
  @spec update(notification :: Notification.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def update(%Notification{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Notification.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
