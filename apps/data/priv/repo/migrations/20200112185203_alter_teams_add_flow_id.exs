defmodule Data.Repo.Migrations.AlterTeamsAddFlowId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:twilio_flow_id, :string)
    end
  end
end
