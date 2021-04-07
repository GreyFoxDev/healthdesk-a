defmodule Data.Repo.Migrations.AlterTableAddRedFlag do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      add(:read, :boolean, default: false)
    end
  end
end
