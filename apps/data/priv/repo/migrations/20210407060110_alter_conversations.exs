defmodule Data.Repo.Migrations.AlterConversations do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:subject, :string)
    end
  end

end

