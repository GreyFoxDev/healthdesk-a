defmodule Security.Data.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
          execute "CREATE EXTENSION citext"
    create table(:users) do
      add(:phone_number, :string, size: 50)
      add(:role, :string)

      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :string)

      add(:status, :string)

      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
