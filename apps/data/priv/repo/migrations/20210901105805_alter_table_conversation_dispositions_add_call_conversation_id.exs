defmodule Data.Repo.Migrations.AlterTableConversationDispositionsAddCallConversationId do
  use Ecto.Migration

  def change do
    alter table(:conversation_dispositions) do
      add :conversation_call_id, references(:conversation_calls)
    end
    create index(:conversation_dispositions, [:conversation_call_id])
  end
end
