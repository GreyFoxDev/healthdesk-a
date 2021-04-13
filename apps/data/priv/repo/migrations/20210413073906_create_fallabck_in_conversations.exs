defmodule Data.Repo.Migrations.CreateFallabckInConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:fallback, :integer, default: 0)
    end
  end
end
