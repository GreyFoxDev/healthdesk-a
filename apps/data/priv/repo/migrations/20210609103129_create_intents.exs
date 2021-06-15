defmodule Data.Repo.Migrations.CreateIntents do
  use Ecto.Migration

  def change do
    create table(:intents, primary_key: false) do
      add(:location_id, references(:locations), primary_key: true)
      add(:intent, :string, primary_key: true)
      add(:message, :string)

      timestamps()
    end
  end
end
