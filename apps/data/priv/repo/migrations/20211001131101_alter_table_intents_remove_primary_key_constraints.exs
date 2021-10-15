defmodule Data.Repo.Migrations.AlterTableIntentsRemovePrimaryKeyConstraints do
  use Ecto.Migration

  def change do
    drop(constraint(:intents, :intents_pk))
      alter table(:intents) do
        add(:id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()"))
      end
      create index(:intents, [:location_id, :intent], unique: true)
  end
end

