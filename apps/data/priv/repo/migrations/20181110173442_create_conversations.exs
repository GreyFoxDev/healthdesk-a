defmodule Data.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add(:location_id, references(:locations))
      add(:team_member_id, references(:team_members))
      add(:original_number, :string)
      add(:status, :string, default: "open")
      add(:started_at, :utc_datetime)

      timestamps()
    end
  end
end
