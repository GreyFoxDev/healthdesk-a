defmodule Data.Repo.Migrations.AlterTableLocationsAddFacebookPageIdAndFacebookToken do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:facebook_page_id, :text, default: nil)
      add(:facebook_token, :text, default: nil)
    end
  end
end
