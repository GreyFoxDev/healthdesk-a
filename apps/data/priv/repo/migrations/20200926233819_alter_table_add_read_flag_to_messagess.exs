defmodule Data.ReadOnly.Repo.Migrations.AlterTableAddMindbodyFieldsToTeams do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      add(:read, :boolean, default: false)
    end
  end
end
