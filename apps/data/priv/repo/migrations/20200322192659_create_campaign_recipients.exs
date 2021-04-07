defmodule Data.Repo.Migrations.CreateCampaignRecipients do
  use Ecto.Migration

  def change do
    create table(:campaign_recipients) do
      add(:recipient_name, :string)
      add(:phone_number, :string)
      add(:sent_at, :utc_datetime)
      add(:sent_successfully, :boolean)

      add(:campaign_id, references(:campaigns))

      timestamps()
    end
  end
end
