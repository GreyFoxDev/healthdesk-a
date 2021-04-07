defmodule Data.Repo.Migrations.CreateClassSchedules do
  use Ecto.Migration

  def change do
    create table(:class_schedules) do

      add(:date, :date)
      add(:start_time, :time)
      add(:end_time, :time)

      add(:instructor, :string)
      add(:class_type, :string)
      add(:class_category, :string)
      add(:class_description, :string)

      add(:location_id, references(:locations))

      timestamps()
    end

  end
end
