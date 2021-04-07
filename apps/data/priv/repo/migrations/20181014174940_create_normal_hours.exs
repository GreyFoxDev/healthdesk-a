defmodule Data.Repo.Migrations.CreateNormalHours do
  use Ecto.Migration

  def change do
    create table(:normal_hours) do
      add(:day_of_week, :string)
      add(:open_at, :string)
      add(:close_at, :string)

      add(:location_id, references(:locations))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end

  end
end
