defmodule Data.Repo.Migrations.DropMatricesSessions do
  use Ecto.Migration

  def change do
    execute "DROP VIEW metrics_facebook_session_totals CASCADE;"
    execute "DROP VIEW metrics_web_session_totals CASCADE;"
    execute "DROP VIEW metrics_sms_session_totals CASCADE;"
    execute "DROP VIEW metrics_sessions CASCADE;"
#    execute "DROP VIEW metrics_teams CASCADE;"
  end
end
