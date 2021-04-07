defmodule Data.Repo.Migrations.AddWebHandleToLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:web_handle, :string)
      add(:web_chat, :boolean)
    end
  end
end
