defmodule Data.Repo.Migrations.AlterTickets do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add(:location_id, references(:locations))
    end
    alter table(:notifications) do
      add(:ticket_id, references(:tickets))
    end
  end

end

