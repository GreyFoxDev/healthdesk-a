defmodule Data.Repo.Migrations.CreateUniqueConstraintUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:phone_number, :deleted_at], where: "deleted_at IS NULL", name: :active_user_phone_number)
  end
end
