defmodule Data.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add(:location_name, :string, size: 250)
      add(:phone_number, :string, size: 50)
      add(:address_1, :string, size: 250)
      add(:address_2, :string, size: 250)
      add(:city, :string, size: 100)
      add(:state, :string, size: 2)
      add(:postal_code, :string, size: 20)

      add(:team_id, references(:teams))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
