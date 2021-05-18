defmodule Data.Repo.Migrations.AddCountryCodeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:country, :string, default: "1")
    end
  end
end
