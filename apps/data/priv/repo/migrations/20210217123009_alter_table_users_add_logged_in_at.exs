defmodule Data.Repo.Migrations.AlterTableUsersAddLoggedInAt do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:logged_in_at, :utc_datetime)
    end
  end
end
