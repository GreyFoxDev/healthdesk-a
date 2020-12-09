defmodule Data.Query.Appointment do

  @moduledoc """
  Module for the Appointment queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Appointment}
  alias Data.ReadOnly.Repo, as: Read
  alias Data.WriteOnly.Repo, as: Write

  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Appointment.t() | nil
  def get(id, repo \\ Read) do
    from(c in Appointment,
      where: c.id == ^id
    )
    |> repo.one()
  end

  @spec get_by_conversation(convo_id :: binary(), repo :: Ecto.Repo.t()) :: [Appointment.t()]
  def get_by_conversation(convo_id, repo \\ Read) do
    from(n in Appointment,
      where: n.conversation_id == ^convo_id,
      where: n.confirmed == false,
      order_by: [desc: n.inserted_at],
    )
    |> repo.all()
  end

  @doc """
  Creates a new Appointment
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Appointment.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    IO.inspect("1123131231321312312312321312312312")
    IO.inspect(1123131231321312312312321312312312)
    IO.inspect("1123131231321312312312321312312312")

    %Appointment{}
    |> Appointment.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)
      changeset ->
        {:error, changeset}
    end
  end

  @doc """
  Updates an existing Appointment
  """
  @spec update(appointment :: Appointment.t(), params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Appointment.t()} | {:error, Ecto.Changeset.t()}
  def update(%Appointment{} = original, params, repo \\ Write) when is_map(params) do
    original
    |> Appointment.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.update(changeset)

      changeset ->
        {:error, changeset}
    end
  end
end
