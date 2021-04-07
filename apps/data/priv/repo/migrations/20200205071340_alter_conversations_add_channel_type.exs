defmodule Data.Repo.Migrations.AlterConversationsAddChannelType do
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:channel_type, :string, size: 20)
    end

    execute """
    UPDATE conversations
    SET channel_type = 'WEB'
    WHERE original_number LIKE 'CH%';
    """

    execute """
    UPDATE conversations
    SET channel_type = 'SMS'
    WHERE original_number LIKE '+1%';
    """

    execute """
    UPDATE conversations
    SET channel_type = 'FACEBOOK'
    WHERE original_number LIKE 'messenger:%';
    """
  end
end
