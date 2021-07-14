defmodule Data.Repo.Migrations.CreateAutomations do
  use Ecto.Migration

  def change do
    create table(:automations) do
      add(:question, :text)
      add(:answer, :text)
      add(:location_id, references(:locations))
      timestamps()
    end
  end
end
