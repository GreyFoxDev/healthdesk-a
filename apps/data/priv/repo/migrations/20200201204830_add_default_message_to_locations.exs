defmodule Data.Repo.Migrations.AddDefaultMessageToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:default_message, :string, size: 500)
    end
  end
end
