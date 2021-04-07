defmodule Data.Repo.Migrations.AlterNormalHours do
  use Ecto.Migration

  def change do
    alter table(:normal_hours) do
      remove(:open_at)
      remove(:close_at)
      add(:times, {:array, :jsonb}, default: [], on_replace: :delete)
    end
  end
end
