defmodule Data.Repo.Migrations.CreateChildCareHours do
  use Ecto.Migration

  def change do
    create table(:child_care_hours) do
      add(:day_of_week, :string)
      add(:morning_open_at, :string)
      add(:morning_close_at, :string)
      add(:afternoon_open_at, :string)
      add(:afternoon_close_at, :string)

      add(:location_id, references(:locations))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end

  end
end
