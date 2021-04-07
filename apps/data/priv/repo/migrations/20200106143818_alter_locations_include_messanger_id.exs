defmodule Data.Repo.Migrations.AlterLocationsIncludeMessangerId do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:messanger_id, :string)
    end
  end
end
