defmodule Data.Repo.Migrations.AlterTableConversationsMessagesModifySentAt do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      modify :sent_at, :naive_datetime_usec
    end
  end
end
