defmodule Data.Repo.Migrations.CreateConversationMessages do
  use Ecto.Migration

  def change do
    create table(:conversation_messages) do
      add(:conversation_id, references(:conversations))

      add(:phone_number, :string)
      add(:message, :string)
      add(:sent_at, :utc_datetime)

      timestamps()
    end
  end
end
