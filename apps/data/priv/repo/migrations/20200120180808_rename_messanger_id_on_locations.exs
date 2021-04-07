defmodule Data.Repo.Migrations.RenameMessangerIdOnLocations do
  use Ecto.Migration

  def change do
    rename table("locations"), :messanger_id, to: :messenger_id
  end
end
