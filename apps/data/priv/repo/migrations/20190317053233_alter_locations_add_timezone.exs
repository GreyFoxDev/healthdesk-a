defmodule Data.Repo.Migrations.AlterLocationsAddTimezone do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:timezone, :string, default: "PST8PDT")
    end
  end
end
