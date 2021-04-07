defmodule Data.Repo.Migrations.CreatePricingPlans do
  use Ecto.Migration

  def change do
    create table(:pricing_plans) do
      add(:has_daily, :boolean)
      add(:daily, :string)
      add(:has_weekly, :boolean)
      add(:weekly, :string)
      add(:has_monthly, :boolean)
      add(:monthly, :string)

      add(:location_id, references(:locations))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
