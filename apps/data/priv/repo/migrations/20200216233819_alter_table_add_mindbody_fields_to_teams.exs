defmodule Data.Repo.Migrations.AlterTableAddMindbodyFieldsToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:use_mindbody, :boolean, default: false)
      add(:mindbody_site_id, :string, size: 20)
    end
  end
end
