defmodule Data.Repo.Migrations.AlterMetricsAddFacebookSessions do
  use Ecto.Migration

  def up do
    execute "DROP view metrics_teams;"

    execute """
    CREATE OR REPLACE VIEW metrics_web_session_totals AS (
    WITH number_of_web_sessions AS (
    SELECT COUNT(DISTINCT cm.conversation_id) AS web_sessions, l.team_id
    FROM conversation_messages AS cm
    INNER JOIN conversations AS c ON cm.conversation_id = c.id
    INNER JOIN locations AS l ON c.location_id = l.id
    WHERE c.original_number LIKE 'CH%'
    GROUP BY l.team_id, date(cm.sent_at)
    ORDER BY l.team_id
    )

    SELECT SUM(web_sessions::integer) AS total_web_sessions,
    team_id
    FROM number_of_web_sessions
    GROUP BY team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_facebook_session_totals AS (
    WITH number_of_facebook_sessions AS (
    SELECT COUNT(DISTINCT cm.conversation_id) AS facebook_sessions, l.team_id
    FROM conversation_messages AS cm
    INNER JOIN conversations AS c ON cm.conversation_id = c.id
    INNER JOIN locations AS l ON c.location_id = l.id
    WHERE c.original_number LIKE 'messenger%'
    GROUP BY l.team_id, date(cm.sent_at)
    ORDER BY l.team_id
    )

    SELECT SUM(facebook_sessions::integer) AS total_facebook_sessions,
    team_id
    FROM number_of_facebook_sessions
    GROUP BY team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
    SELECT t.team_id, teammates,
    COALESCE(location_admins, 0) as location_admins, locations, bounce_rate,
    inbound_messages, members, total_sessions,
    ROUND(inbound_messages / members) AS average_messages_per_member,
    ROUND(total_sessions / members) AS average_sessions_per_member,
    COALESCE(total_sms_sessions, 0) as total_sms_sessions,
    COALESCE(total_web_sessions, 0) as total_web_sessions,
    COALESCE(total_facebook_sessions, 0) as total_facebook_sessions
    FROM metrics_teammates AS t
    INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
    LEFT JOIN metrics_location_admins AS la ON t.team_id = la.team_id
    INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
    INNER JOIN metrics_inbound_messages AS im ON t.team_id = im.team_id
    INNER JOIN metrics_members AS m ON t.team_id = m.team_id
    INNER JOIN metrics_sessions AS s ON t.team_id = s.team_id
    LEFT JOIN metrics_sms_session_totals AS sms ON t.team_id = sms.team_id
    LEFT JOIN metrics_web_session_totals AS web ON t.team_id = web.team_id
    LEFT JOIN metrics_facebook_session_totals AS facebook ON t.team_id = facebook.team_id
    );
    """

  end

  def down do
    execute "DROP view metrics_teams;"
    execute "DROP view metrics_facebook_session_totals;"

    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
    SELECT t.team_id, teammates,
    COALESCE(location_admins, 0) as location_admins, locations, bounce_rate,
    inbound_messages, members, total_sessions,
    ROUND(inbound_messages / members) AS average_messages_per_member,
    ROUND(total_sessions / members) AS average_sessions_per_member,
    COALESCE(total_sms_sessions, 0) as total_sms_sessions,
    COALESCE(total_web_sessions, 0) as total_web_sessions,
    COALESCE(total_facebook_sessions, 0) as total_facebook_sessions
    FROM metrics_teammates AS t
    INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
    LEFT JOIN metrics_location_admins AS la ON t.team_id = la.team_id
    INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
    INNER JOIN metrics_inbound_messages AS im ON t.team_id = im.team_id
    INNER JOIN metrics_members AS m ON t.team_id = m.team_id
    INNER JOIN metrics_sessions AS s ON t.team_id = s.team_id
    LEFT JOIN metrics_sms_session_totals AS sms ON t.team_id = sms.team_id
    LEFT JOIN metrics_web_session_totals AS web ON t.team_id = web.team_id
    );
    """

  end

end
