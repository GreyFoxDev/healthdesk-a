defmodule Data.Repo.Migrations.AlterMessageColumnSize do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      modify :message, :text
    end
  end
end
