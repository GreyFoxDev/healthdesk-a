defmodule Data.ReadOnly.Repo.Migrations.CreateIndexOnOptinForPhoneNumber do
  use Ecto.Migration

  def change do
    create index(:opt_ins, [:phone_number])
  end
end
