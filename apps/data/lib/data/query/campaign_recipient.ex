defmodule Data.Query.CampaignRecipient do
  @moduledoc """
  Module for the Pricing Plan queries
  """
  import Ecto.Query, only: [from: 2]

  alias Data.Schema.CampaignRecipient
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @doc """
  Returns a campaign recipient by id
  """
  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: CampaignRecipient.t() | nil
  def get(id, repo \\ Read) do
    from(t in CampaignRecipient,
      where: t.id == ^id
    )
    |> repo.one()
  end

  @doc """
  Return a list of active campaign recipient for a campaign
  """
  @spec get_by_campaign_id(campaign_id :: binary(), repo :: Ecto.Repo.t()) :: [
          CampaignRecipient.t()
        ]
  def get_by_campaign_id(campaign_id, repo \\ Read) do
    from(t in CampaignRecipient,
      where: t.campaign_id == ^campaign_id
    )
    |> repo.all()
  end

  @doc """
  Creates a new campaign recipient
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, CampaignRecipient.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %CampaignRecipient{}
    |> CampaignRecipient.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing campaign recipient
  """
  @spec update(recipient :: CampaignRecipient.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, CampaignRecipient.t()} | {:error, Ecto.Changeset.t()}
  def update(%CampaignRecipient{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> CampaignRecipient.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
