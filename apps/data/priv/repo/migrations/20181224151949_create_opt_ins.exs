defmodule Data.Repo.Migrations.CreateOptIns do
  use Ecto.Migration

  def change do
    create table(:opt_ins) do
      add(:phone_number, :string, size: 50)
      add(:status, :string, default: "no")

      timestamps()
    end
  end
end
