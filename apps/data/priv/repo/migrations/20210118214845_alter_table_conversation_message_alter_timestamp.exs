defmodule Data.Repo.Migrations.AlterTableConversationMessageAlterTimestamp do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      modify :inserted_at, :naive_datetime_usec
      modify :updated_at, :naive_datetime_usec
    end
  end
end
