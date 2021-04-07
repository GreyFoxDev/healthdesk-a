defmodule Data.Repo.Migrations.AlterChildCareHours do
  use Ecto.Migration

    def change do
      alter table(:child_care_hours) do
        remove(:morning_open_at)
        remove(:morning_close_at)
        remove(:afternoon_open_at)
        remove(:afternoon_close_at)
        add(:times, {:array, :jsonb}, default: [], on_replace: :delete)
      end
  end
end
