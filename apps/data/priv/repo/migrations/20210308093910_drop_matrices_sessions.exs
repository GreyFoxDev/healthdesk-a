defmodule Data.ReadOnly.Repo.Migrations.DropMatricesSessions do
  use Ecto.Migration

  def change do
    execute "DROP VIEW IF EXISTS metrics_facebook_session_totals CASCADE;"
    execute "DROP VIEW IF EXISTS metrics_web_session_totals CASCADE;"
    execute "DROP VIEW IF EXISTS metrics_sms_session_totals CASCADE;"
    execute "DROP VIEW IF EXISTS metrics_sessions CASCADE;"
    execute "DROP VIEW IF EXISTS metrics_teams CASCADE;"
  end
end
