defmodule Data.Repo.Migrations.CreateSavedReplies do
  use Ecto.Migration

  def change do
    create table(:saved_reply) do
      add(:location_id, references(:locations))
      add(:title, :string)
      add(:draft, :string)

      timestamps()
    end
  end
end
