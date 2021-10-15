defmodule Data.Repo.Migrations.AlterTableTeamsAddPhoneNumberField do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:phone_number, :string, default: nil)
    end
  end
end
