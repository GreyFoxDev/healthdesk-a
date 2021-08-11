defmodule Data.Repo.Migrations.AlterTableLocationsAddBotId do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :bot_id, :string, default: nil
    end
  end
end
