defmodule Data.Repo.Migrations.CreateConversationCalls do
  use Ecto.Migration

  def change do
    create table(:conversation_calls) do
      add(:location_id, references(:locations))
      add(:team_member_id, references(:team_members))
      add(:original_number, :string)
      add(:status, :string, default: "open")
      add(:started_at, :utc_datetime)
      add(:fallback, :integer, default: 0)
      add(:appointment, :boolean, default: false)
      add(:step, :integer)
      add(:subject, :string)

      timestamps()
    end
  end
end
