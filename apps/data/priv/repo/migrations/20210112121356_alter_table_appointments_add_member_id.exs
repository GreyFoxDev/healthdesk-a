defmodule Data.ReadOnly.Repo.Migrations.AlterTableAppointmentsAddMemberId do
  use Ecto.Migration

  def change do
    alter table(:appointments) do
      add(:memeber_id, :string)
    end
  end
end
