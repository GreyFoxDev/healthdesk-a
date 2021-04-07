defmodule Data.Repo.Migrations.AlterTeamMembersAddDeletedAt do
  use Ecto.Migration

  def change do
    alter table(:team_members) do
      add(:deleted_at, :utc_datetime)
    end
  end
end
