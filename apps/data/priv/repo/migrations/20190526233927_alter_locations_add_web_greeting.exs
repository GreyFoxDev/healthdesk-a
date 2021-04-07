defmodule Data.Repo.Migrations.AlterLocationsAddWebGreeting do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:web_greeting, :text)
    end
  end
end
