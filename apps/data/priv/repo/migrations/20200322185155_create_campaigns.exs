defmodule Data.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add(:campaign_name, :string)
      add(:message, :text)
      add(:scheduled, :boolean)
      add(:send_at, :utc_datetime)
      add(:completed, :boolean, default: false)

      add(:location_id, references(:locations))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
