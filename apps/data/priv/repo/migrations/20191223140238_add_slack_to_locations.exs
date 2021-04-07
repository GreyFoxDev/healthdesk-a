defmodule Data.Repo.Migrations.AddSlackToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:slack_integration, :string)
    end
  end
end
