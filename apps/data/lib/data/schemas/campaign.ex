defmodule Data.Schema.Campaign do
  @moduledoc """
  The schema for a location's campaigns
  """
  use Data.Schema

  @type t :: %__MODULE__{
          id: binary(),
          location_id: binary(),
          campaign_name: String.t() | nil,
          scheduled: :boolean | nil,
          completed: :boolean | nil,
          send_at: :utc_datetime | nil,
          deleted_at: :utc_datetime | nil
        }

  @required_fields ~w|
  location_id
  |a

  @optional_fields ~w|
  scheduled
  completed
  campaign_name
  message
  send_at
  deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "campaigns" do
    field(:campaign_name, :string)
    field(:message, :string)
    field(:scheduled, :boolean)
    field(:completed, :boolean)
    field(:send_at, :utc_datetime)

    field(:deleted_at, :utc_datetime)

    belongs_to(:location, Data.Schema.Location)

    has_many(:campaign_recipients, Data.Schema.CampaignRecipient)

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
end
