defmodule Data.Repo.Migrations.AlterChildCareHoursIncludeBooleans do
  use Ecto.Migration

  def change do
    alter table(:child_care_hours) do
      add(:active, :boolean, default: false)
    end
  end
end
