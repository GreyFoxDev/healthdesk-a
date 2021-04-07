defmodule Data.Repo.Migrations.AlterChildCareHoursAndHolidayHours do
  use Ecto.Migration

  def change do
    alter table(:child_care_hours) do
      add(:closed, :boolean, default: false)
    end

    alter table(:holiday_hours) do
      add(:closed, :boolean, default: false)
    end
  end
end
