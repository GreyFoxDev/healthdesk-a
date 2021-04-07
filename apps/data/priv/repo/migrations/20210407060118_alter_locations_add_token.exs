defmodule Data.Repo.Migrations.AlterLocationsAddToken do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:google_token, :text, default: nil)
      add(:google_refresh_token, :text, default: nil)
      add(:calender_id, :text, default: nil)
    end
  end
end
