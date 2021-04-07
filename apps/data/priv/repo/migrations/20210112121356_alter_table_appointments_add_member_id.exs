defmodule Data.Repo.Migrations.AlterTableAppointmentsAddMemberId do
  use Ecto.Migration

  def change do
    alter table(:appointments) do
      add(:member_id, references(:members))
    end
  end
end
