defmodule Data.Repo.Migrations.AlterLocationAddAutomationLimit do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:automation_limit, :integer, default: 3)
    end
  end
end

