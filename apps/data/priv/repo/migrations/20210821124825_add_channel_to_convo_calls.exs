defmodule Data.Repo.Migrations.AddChannelToConvoCalls do
    use Ecto.Migration

    def change do
      alter table(:conversation_calls) do
        add(:channel_type, :string, size: 20)
      end
      create index(:conversation_calls, [:original_number])
    end
  end
