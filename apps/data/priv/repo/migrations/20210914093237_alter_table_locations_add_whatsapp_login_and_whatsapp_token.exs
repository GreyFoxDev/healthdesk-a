defmodule Data.Repo.Migrations.AlterTableLocationsAddWhatsappLoginAndWhatsappToken do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:whatsapp_login, :boolean, default: false)
      add(:whatsapp_token, :text, default: nil)
    end
  end
end
