defmodule Data.Query.ConversationDisposition do
  @moduledoc """
  Module for the Conversation Disposition queries
  """

  alias Data.Schema.ConversationDisposition
  alias Data.Repo, as: Read
  alias Data.Repo, as: Write
  alias Ecto.Adapters.SQL

  @cols [
    :disposition_count,
    :disposition_date,
    :channel_type
  ]

  @query1 "SELECT * FROM count_team_dispositions_by_channel_type($1, $2);"
  @query2 "SELECT * FROM count_location_dispositions_by_channel_type($1, $2);"
  @query3 "SELECT * FROM count_dispositions_by_channel_type($1);"

  @doc """
  Creates a new conversation disposition
  """
  @spec create(params :: map(), repo :: Ecto.Repo.t()) ::
          {:ok, ConversationDisposition.t()} | {:error, Ecto.Changeset.t()}
  def create(params, repo \\ Write) do
    %ConversationDisposition{}
    |> ConversationDisposition.changeset(params)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        repo.insert(changeset)

      changeset ->
        {:error, changeset}
    end
  end

  def count_channel_type_by_team_id(channel_type, team_id, repo \\ Read) do
    repo
    |> SQL.query!(@query1, [team_id, channel_type])
    |> build_results()
  end

  def count_channel_type_by_location_id(channel_type, location_id, repo \\ Read) do
    repo
    |> SQL.query!(@query2, [location_id, channel_type])
    |> build_results()
  end

  def count_all_by_channel_type(channel_type, repo \\ Read) do
    repo
    |> SQL.query!(@query3, [channel_type])
    |> build_results()
  end

  defp build_results(results) do
    Enum.map(results.rows, fn row -> Map.new(Enum.zip(@cols, row)) end)
  end
end
