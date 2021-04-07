defmodule Data.Repo.Migrations.CreateHolidayHours do
  use Ecto.Migration

  def change do
    create table(:holiday_hours) do
      add(:holiday_name, :string)
      add(:holiday_date, :utc_datetime)
      add(:open_at, :string)
      add(:close_at, :string)

      add(:location_id, references(:locations))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
