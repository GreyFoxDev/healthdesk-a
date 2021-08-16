defmodule Data.Repo.Migrations.AlterTeamsSubAccountId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:sub_account_id, :string)
    end
  end
end
