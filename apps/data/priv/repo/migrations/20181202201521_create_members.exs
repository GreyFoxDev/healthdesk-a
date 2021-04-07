defmodule Data.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add(:phone_number, :string, size: 50)

      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :string)
      add(:status, :string)
      add(:team_id, references(:teams))
      add(:consent, :boolean)

      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
