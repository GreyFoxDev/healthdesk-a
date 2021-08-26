defmodule Data.Repo.Migrations.AlterTeamsAddBotIdAgains do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:bot_id, :string,  default: Application.get_env(:wit_client, :access_token))
    end
  end

end
