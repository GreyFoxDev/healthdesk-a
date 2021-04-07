defmodule Data.Repo.Migrations.CreateTeamMembers do
  use Ecto.Migration

  def change do
    create table(:team_members) do
      add(:location_id, references(:locations))
      add(:user_id, references(:users))
    end
  end
end
