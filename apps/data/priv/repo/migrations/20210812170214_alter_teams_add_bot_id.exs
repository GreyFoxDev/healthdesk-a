defmodule Data.Repo.Migrations.AlterTeamsAddBotId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:bot_id, :string)
    end
  end
end
