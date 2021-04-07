defmodule Data.Repo.Migrations.AlterTableNormalHoursAddClosed do
  use Ecto.Migration

  def change do
    alter table(:normal_hours) do
      add(:closed, :boolean, default: false)
    end
  end
end
