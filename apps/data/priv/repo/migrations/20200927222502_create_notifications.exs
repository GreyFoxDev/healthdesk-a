defmodule Data.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add(:text, :string)
      add(:conversation_id, references(:conversations))
      add(:from, references(:users))
      add(:user_id, references(:users))
      add(:read, :boolean)


      timestamps()
    end
  end
end
