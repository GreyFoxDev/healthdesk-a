defmodule Data.Repo.Migrations.CreateMemberChannels do
  use Ecto.Migration

  def change do
    create table(:member_channels) do
      add(:member_id, references(:members))
      add(:channel_id, :string, size: 250)

      timestamps()
    end

    create index(:member_channels, [:channel_id])
  end
end
