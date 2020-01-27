defmodule Data.Query.MemberChannelTest do
  @moduledoc """
  Tests for the Member Channel Query module
  """
  use Data.DataCase

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Query.MemberChannel, as: Query
  alias Data.Schema.MemberChannel

  setup do
    team = insert(:team, %{team_name: "Your Fitness Gym"})
    member = insert(:member, %{team_id: team.id, phone_number: phone_number()})
    {:ok, member: member}
  end

  describe "get/1" do
    test "returns nil if record is not found" do
      refute Query.get(UUID.uuid4(), Repo)
    end

    test "returns member channel with a valid id", %{member: member} do
      member_channel = insert(:member_channel, %{channel_id: "CH111111", member_id: member.id})

      assert member_channel == Query.get(member_channel.id, Repo)
      assert member_channel.member_id == member.id
      assert member_channel.channel_id == "CH111111"
    end
  end

  describe "get_by_member_id/1" do
    setup context do
      insert_list(3, :member_channel, %{
        member_id: context.member.id,
        channel_id: "CH#{Enum.random(100..1000)}"
      })

      {:ok, context}
    end

    test "returns nil if record is not found" do
      assert [] = Query.get_by_member_id(UUID.uuid4(), Repo)
    end

    test "returns a member channel using the member id", %{member: member} do
      member2 = insert(:member, %{phone_number: phone_number(), team_id: member.team_id})
      _ = insert(:member_channel, %{member_id: member2.id, channel_id: "CH111111"})

      # There should be 3 from the setup
      assert 3 = Query.get_by_member_id(member.id, Repo) |> Enum.count()
      # There should be 1 that was inserted above
      assert [found] = Query.get_by_member_id(member2.id, Repo)
      assert found.channel_id == "CH111111"
    end
  end

  describe "get_by_channel_id/1" do
    setup context do
      insert_list(3, :member_channel, %{
        member_id: context.member.id,
        channel_id: "CH#{Enum.random(100..1000)}"
      })

      {:ok, context}
    end

    test "returns nil if record is not found" do
      assert [] = Query.get_by_channel_id("NOT-A-CHANNEL", Repo)
    end

    test "returns a member channel using the channel id", %{member: member} do
      member2 = insert(:member, %{phone_number: phone_number(), team_id: member.team_id})
      _ = insert(:member_channel, %{member_id: member2.id, channel_id: "CH111111"})

      # There should be 1 that was inserted above
      assert [found] = Query.get_by_channel_id("CH111111", Repo)
      assert found.channel_id == "CH111111"
      assert found.member_id == member2.id
    end
  end

  describe "create/1" do
    test "returns error if the required fields are missing" do
      assert {:error, %Ecto.Changeset{errors: errors}} = Query.create(%{})

      assert errors == [
               channel_id: {"can't be blank", [validation: :required]},
               member_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "returns the created member channel on success", %{member: member} do
      params = %{
        member_id: member.id,
        channel_id: "CH111111"
      }

      assert {:ok, %MemberChannel{} = member_channel} = Query.create(params, Repo)
      assert "CH111111" == member_channel.channel_id
      assert member.id == member_channel.member_id
    end
  end
end
