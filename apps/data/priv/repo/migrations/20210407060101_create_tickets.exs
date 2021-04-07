defmodule Data.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add(:description, :string)
      add(:status, :string)
      add(:priority, :string)
      add(:user_id, references(:users))
      add(:team_member_id, references(:team_members))
      timestamps()
    end
    flush()
    create table(:ticket_notes) do
      add(:note, :string)
      add(:user_id, references(:users))
      add(:ticket_id, references(:tickets))
      timestamps()
    end
  end

end

