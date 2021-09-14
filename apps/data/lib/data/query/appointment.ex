defmodule Data.Query.Appointment do
  @moduledoc """
  Module for the Appointment queries
  """

  import Ecto.Query, only: [from: 2]

  alias Data.Schema.{Appointment}
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write

  @spec get(id :: binary(), repo :: Ecto.Repo.t()) :: Appointment.t() | nil
  def get(id, repo \\ Read) do
    from(c in Appointment,
      where: c.id == ^id,
      preload: [:conversation]
    )
    |> repo.one()
  end

  @spec get_by_conversation(convo_id :: binary(), repo :: Ecto.Repo.t()) :: [Appointment.t()]
  def get_by_conversation(convo_id, repo \\ Read) do
    from(n in Appointment,
      where: n.conversation_id == ^convo_id,
      where: n.confirmed == false,
      order_by: [desc: n.inserted_at],
      preload: [:conversation]
    )
    |> repo.all()
  end

  @doc """
  Creates a new Appointment
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, Appointment.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
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

  @spec count_all(to :: String.t(), from :: String.t(), repo :: Ecto.Repo.t()) :: [map()]
  def count_all(to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(a in Data.Schema.Appointment,
        group_by: [a.confirmed],
        distinct: [a.confirmed],
        order_by: a.confirmed,
        select: %{confirmed: a.confirmed, count: count(a.id)}
      )

    Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to), do: query, else: from([a, ...] in query, where: a.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from), do: query, else: from([a, ...] in query, where: a.inserted_at >= ^from)

      _, query ->
        query
    end)
    |> repo.all()
  end

  @doc """
  Return a list of dispositions with count of usage by team
  """
  @spec count_by_team_id(
          team_id :: binary(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: [map()]
  def count_by_team_id(team_id, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(a in Data.Schema.Appointment,
        join: c in assoc(a, :conversation),
        join: l in assoc(c, :location),
        group_by: [a.confirmed],
        where: l.team_id == ^team_id,
        distinct: [a.confirmed],
        order_by: [a.confirmed],
        select: %{confirmed: a.confirmed, count: count(a.id)}
      )

    Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to), do: query, else: from([a, ...] in query, where: a.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from), do: query, else: from([a, ...] in query, where: a.inserted_at >= ^from)

      _, query ->
        query
    end)
    |> repo.all()
  end

  @doc """
  Return a list of dispositions with count of usage by location
  """
  @spec count_by_location_id(location_id :: binary(), repo :: Ecto.Repo.t()) :: [map()]
  def count_by_location_id(location_id, repo \\ Read) do
    from(a in Data.Schema.Appointment,
      join: c in assoc(a, :conversation),
      join: l in assoc(c, :location),
      group_by: [a.confirmed],
      where: l.id == ^location_id,
      distinct: [a.confirmed],
      order_by: [a.confirmed],
      select: %{confirmed: a.confirmed, count: count(a.id)}
    )
    |> repo.all()
  end

  @doc """
  Return a list of dispositions with count of usage by locations
  """
  @spec count_by_location_ids(
          location_ids :: binary(),
          to :: String.t(),
          from :: String.t(),
          repo :: Ecto.Repo.t()
        ) :: [map()]
  def count_by_location_ids(location_ids, to, from, repo \\ Read) do
    to = Data.Disposition.convert_string_to_date(to)
    from = Data.Disposition.convert_string_to_date(from)

    query =
      from(a in Data.Schema.Appointment,
        join: c in assoc(a, :conversation),
        join: l in assoc(c, :location),
        group_by: [a.confirmed],
        where: l.id in ^location_ids,
        distinct: [a.confirmed],
        order_by: [a.confirmed],
        select: %{confirmed: a.confirmed, count: count(a.id)}
      )

    Enum.reduce(%{to: to, from: from}, query, fn
      {:to, to}, query ->
        if is_nil(to), do: query, else: from([a, ...] in query, where: a.inserted_at <= ^to)

      {:from, from}, query ->
        if is_nil(from), do: query, else: from([a, ...] in query, where: a.inserted_at >= ^from)

      _, query ->
        query
    end)
    |> repo.all()
  end
end
