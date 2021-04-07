defmodule Data.Repo.Migrations.CreateIndexOnConversationForPhoneNumber do
  use Ecto.Migration

  def change do
    create index(:conversations, [:original_number])
  end
end
