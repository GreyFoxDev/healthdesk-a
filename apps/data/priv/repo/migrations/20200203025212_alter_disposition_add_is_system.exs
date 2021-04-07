defmodule Data.Repo.Migrations.AlterDispositionAddIsSystem do
  use Ecto.Migration

  def change do
    alter table(:dispositions) do
      add(:is_system, :boolean, default: false)
    end
  end
end
