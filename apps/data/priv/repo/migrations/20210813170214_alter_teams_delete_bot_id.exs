defmodule Data.Repo.Migrations.AlterTeamsDeleteBotId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove(:bot_id, :string)
    end
  end
end
