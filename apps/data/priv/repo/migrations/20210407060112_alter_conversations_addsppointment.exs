defmodule Data.Repo.Migrations.AlterConversationsAddAppointment do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:appointment, :boolean, default: false)
      add(:step, :integer)
    end
  end

end

