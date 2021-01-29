defmodule Data.Schema.CampaignRecipient do
  @moduledoc """
  The schema for campaign recipients
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          campaign_id: binary(),
          recipient_name: String.t() | nil,
          phone_number: String.t(),
          sent_at: :utc_datetime | nil,
          sent_successfully: :boolean | nil
        }

  @required_fields ~w|
  campaign_id
  phone_number
  |a

  @optional_fields ~w|
  recipient_name
  sent_at
  sent_successfully
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "campaign_recipients" do
    field(:recipient_name, :string)
    field(:phone_number, :string)
    field(:sent_at, :utc_datetime)
    field(:sent_successfully, :boolean)

    belongs_to(:campaign, Data.Schema.Campaign)
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
