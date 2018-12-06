defmodule Data.ReadOnly.Repo.Migrations.AlterNormalHoursIncludeBooleans do
  use Ecto.Migration

  def change do
    alter table(:normal_hours) do
      add(:active, :boolean, default: false)
    end
  end
end
