defmodule Data.Repo.Migrations.CreateConversationDispositions do
  use Ecto.Migration

  def change do
    create table(:conversation_dispositions) do
      add(:conversation_id, references(:conversations))
      add(:disposition_id, references(:dispositions))

      timestamps()
    end
  end
end
