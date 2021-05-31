defmodule Data.Repo.Migrations.AlterTableCampaignRecipientsAddEmail do
  use Ecto.Migration

  def change do
    alter table(:campaign_recipients) do
      add :email, :string, default: nil
    end
  end
end
