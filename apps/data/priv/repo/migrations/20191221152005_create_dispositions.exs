defmodule Data.Repo.Migrations.CreateDispositions do
  use Ecto.Migration

  def change do
    create table(:dispositions) do
      add(:disposition_name, :string)
      add(:team_id, references(:teams))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
