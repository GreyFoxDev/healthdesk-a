defmodule Data.Repo.Migrations.AlterTeamsSubAccountId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:twilio_sub_account_id, :string, default: Map.fetch!(System.get_env(), "FLEX_TWILIO_ACCOUNT_SID"))
    end
  end
end
