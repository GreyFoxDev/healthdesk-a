defmodule Data.Repo.Migrations.CreateTeamMemberLocations do
  use Ecto.Migration

  def up do
    create table(:team_member_locations) do
      add(:team_member_id, references(:team_members))
      add(:location_id, references(:locations))
    end

    execute """
    INSERT INTO team_member_locations
    (id, team_member_id, location_id) (
      SELECT uuid_generate_v4(), id, location_id FROM team_members
    );
    """
  end

  def down do
    drop table(:team_member_locations)
  end
end
