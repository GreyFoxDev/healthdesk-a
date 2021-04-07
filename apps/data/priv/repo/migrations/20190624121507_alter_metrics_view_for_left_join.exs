defmodule Data.Repo.Migrations.AlterMetricsViewForLeftJoin do
  use Ecto.Migration

  def up do
    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
      SELECT t.team_id, teammates, location_admins, locations, bounce_rate,
        inbound_messages, members, total_sessions,
        ROUND(inbound_messages / members) AS average_messages_per_member,
        ROUND(total_sessions / members) AS average_sessions_per_member,
        total_sms_sessions,
        total_web_sessions
      FROM metrics_teammates AS t
      INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
      INNER JOIN metrics_location_admins AS la ON t.team_id = la.team_id
      INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
      INNER JOIN metrics_inbound_messages AS im ON t.team_id = im.team_id
      INNER JOIN metrics_members AS m ON t.team_id = m.team_id
      INNER JOIN metrics_sessions AS s ON t.team_id = s.team_id
      LEFT JOIN metrics_sms_session_totals AS sms ON t.team_id = sms.team_id
      LEFT JOIN metrics_web_session_totals AS web ON t.team_id = web.team_id
    );
    """
  end

  def down do
    execute "DROP VIEW IF EXISTS metrics_teams;"
    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
      SELECT t.team_id, teammates, location_admins, locations, bounce_rate,
        inbound_messages, members, total_sessions,
        ROUND(inbound_messages / members) AS average_messages_per_member,
        ROUND(total_sessions / members) AS average_sessions_per_member,
        total_sms_sessions,
        total_web_sessions
      FROM metrics_teammates AS t
      INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
      INNER JOIN metrics_location_admins AS la ON t.team_id = la.team_id
      INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
      INNER JOIN metrics_inbound_messages AS im ON t.team_id = im.team_id
      INNER JOIN metrics_members AS m ON t.team_id = m.team_id
      INNER JOIN metrics_sessions AS s ON t.team_id = s.team_id
      INNER JOIN metrics_sms_session_totals AS sms ON t.team_id = sms.team_id
      INNER JOIN metrics_web_session_totals AS web ON t.team_id = web.team_id
    );
    """
  end
end
