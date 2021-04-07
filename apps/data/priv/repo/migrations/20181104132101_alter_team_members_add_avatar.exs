defmodule Data.Repo.Migrations.AlterTeamMembersAddAvatar do
  use Ecto.Migration

  def change do
    alter table(:team_members) do
      add(:avatar, :string, default: "")
    end
  end
end
