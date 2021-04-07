defmodule Data.Repo.Migrations.AddCalenderUrlAndFormUrl do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:calender_url, :string)
      add(:form_url, :string)
    end
  end
end
