defmodule Data.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table(:appointments) do
      add(:conversation_id, references(:conversations))
      add(:name, :string)
      add(:email, :string)
      add(:phone, :string)
      add(:date, :string)
      add(:time, :string)
      add(:link, :string)
      add(:type, :string)
      add(:confirmed, :boolean, default: false)
      timestamps()
    end
  end
end
