defmodule Data.Repo.Migrations.AlterLocationsAddApiKey do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:api_key, :string)
    end
  end
end
