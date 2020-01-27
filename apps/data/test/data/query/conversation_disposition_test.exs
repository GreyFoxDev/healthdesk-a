defmodule Data.Query.ConversationDispositionTest do
  @moduledoc """
  Tests for the Conversation Disposition Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.ConversationDisposition, as: Query
  alias Data.Schema.ConversationDisposition

  setup do
    team = insert(:team)
    location = insert(:location, %{team_id: team.id})

    {:ok, team: team, location: location}
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               conversation_id: {"can't be blank", [validation: :required]},
               disposition_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created team on success", %{team: team, location: location} do
      conversation =
        insert(:conversation, %{location_id: location.id, original_number: phone_number()})

      disposition = insert(:disposition, %{team_id: team.id})

      params = %{
        conversation_id: conversation.id,
        disposition_id: disposition.id
      }

      assert {:ok, %ConversationDisposition{} = disposition} = Query.create(params, Repo)
    end
  end
end
