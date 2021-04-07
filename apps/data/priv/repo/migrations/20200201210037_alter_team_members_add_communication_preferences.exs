defmodule Data.Repo.Migrations.AlterUsersAddCommunicationPreferences do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:use_email, :boolean, default: false)
      add(:use_sms, :boolean, default: true)
      add(:use_do_not_disturb, :boolean, default: false)
      add(:timezone, :string, default: "PST8PDT")
      add(:start_do_not_disturb, :string)
      add(:end_do_not_disturb, :string)
    end
  end
end
