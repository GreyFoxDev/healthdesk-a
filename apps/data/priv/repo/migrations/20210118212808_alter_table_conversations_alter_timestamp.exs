defmodule Data.Repo.Migrations.AlterTableConversationsAddTimestamp do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      modify(:inserted_at, :naive_datetime_usec)
      modify(:updated_at, :naive_datetime_usec)
    end
  end
end
