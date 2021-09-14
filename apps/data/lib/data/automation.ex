defmodule Data.Automation do
  @moduledoc """
  This is the for Automations
  """
  alias Data.Schema.Automation
  import Ecto.Query, only: [from: 2]
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Data.Schema.Automation, as: Schema

  def create(params, repo \\ Write) do
    %Automation{}
    |> Automation.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  def get_by_location_id(location_id, repo \\ Read) do
    from(a in Automation,
      where: a.location_id == ^location_id,
      order_by: a.inserted_at,
      preload: [:location]
    )
    |> repo.all()
  end

  def get_by(id, repo \\ Read) do
    from(a in Automation,
      where: a.id == ^id,
      preload: [:location]
    )
    |> repo.one()
  end

  def update(%Automation{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Automation.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  def delete(%Automation{} = automation, repo \\ Write) do
    automation
    |> case do
      %Automation{} = automation ->
        repo.delete(automation)

      nil ->
        {:error, :no_record_found}
    end
  end

  def get_changeset(),
    do: Schema.changeset(%Schema{})
end
