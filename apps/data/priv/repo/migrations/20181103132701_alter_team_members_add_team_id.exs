defmodule Data.Repo.Migrations.AlterTeamMembersAddTeamId do
  use Ecto.Migration

  def change do
    alter table(:team_members) do
      add(:team_id, references(:teams))
    end
  end
end
