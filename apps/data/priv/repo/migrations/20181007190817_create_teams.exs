defmodule Data.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:team_name, :string, size: 250)
      add(:website, :string, size: 250)
      add(:team_member_count, :integer)

      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
