defmodule Data.Schema.CampaignRecipientTest do
  use ExUnit.Case

  alias Data.Schema.CampaignRecipient

  test "validate required fields" do
    assert %{valid?: false, errors: errors} =
             CampaignRecipient.changeset(%CampaignRecipient{}, %{})

    assert errors == [
             campaign_id: {"can't be blank", [validation: :required]},
             phone_number: {"can't be blank", [validation: :required]}
           ]

    assert %{valid?: true, errors: []} =
             CampaignRecipient.changeset(%CampaignRecipient{}, %{
               campaign_id: UUID.uuid4(),
               phone_number: "000 555-1212"
             })
  end
end
