defmodule Data.Query.MemberChannel do
  @moduledoc """
  Module for the Member Channel queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.MemberChannel
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a member channel by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: MemberChannel.t() | nil
  def get(id, repo \\ Read) do
    from(t in MemberChannel,
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a single active member by a unique member id
  """
  @spec get_by_member_id(member_id :: String.t(), repo :: Ecto.Repo.t()) :: [MemberChannel.t()]
  def get_by_member_id(member_id, repo \\ Read) do
    from(t in MemberChannel,
      where: t.member_id == ^member_id
    )
    |> repo.all()
  end

  @doc """
  Return a single active member by a unique channel id
  """
  @spec get_by_channel_id(channel_id :: String.t(), repo :: Ecto.Repo.t()) :: [MemberChannel.t()]
  def get_by_channel_id(channel_id, repo \\ Read) do
    from(t in MemberChannel,
      where: t.channel_id == ^channel_id,
      preload: [:member]
    )
    |> repo.all()
  end

  @doc """
  Creates a new member
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, MemberChannel.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %MemberChannel{}
    |> MemberChannel.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
