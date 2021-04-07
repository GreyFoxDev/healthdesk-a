defmodule Data.Repo.Migrations.CreateWifiNetworks do
  use Ecto.Migration

  def change do
    create table(:wifi_networks) do
      add(:network_name, :string)
      add(:network_pword, :string)

      add(:location_id, references(:locations))
      add(:deleted_at, :utc_datetime)

      timestamps()
    end
  end
end
