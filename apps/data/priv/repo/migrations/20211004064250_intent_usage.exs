defmodule Data.Repo.Migrations.IntentUsage do
  use Ecto.Migration

  def change do
    create table(:intent_usage)do
      add(:intent, :string)
      add(:message_id, references(:conversation_messages))

      timestamps()
    end
    create index(:intent_usage, :message_id)
  end
end
