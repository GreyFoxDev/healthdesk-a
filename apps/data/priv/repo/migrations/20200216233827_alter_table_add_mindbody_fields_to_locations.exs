defmodule Data.Repo.Migrations.AlterTableAddMindbodyFieldsToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:mindbody_location_id, :string, size: 20)
    end
  end
end
