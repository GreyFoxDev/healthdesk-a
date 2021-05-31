defmodule Data.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add(:text, :text)
      add(:conversation_id, references(:conversations))
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
