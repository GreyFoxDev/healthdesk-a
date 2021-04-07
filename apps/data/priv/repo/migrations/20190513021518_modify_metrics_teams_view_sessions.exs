defmodule Data.Repo.Migrations.ModifyMetricsTeamsViewSessions do
  use Ecto.Migration

  def up do

    execute """
    CREATE OR REPLACE VIEW metrics_sessions AS (
      WITH number_of_sessions AS (
        SELECT count(*) AS sessions, l.team_id
        FROM conversation_messages AS cm
        INNER JOIN conversations AS c ON cm.conversation_id = c.id
        INNER JOIN locations AS l ON c.location_id = l.id
        GROUP BY l.team_id, date(cm.sent_at)
        ORDER BY l.team_id
      )
      SELECT SUM(sessions::integer) AS total_sessions, team_id
      FROM number_of_sessions
      GROUP BY team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_members AS (
      SELECT count(*) AS members, team_id
      FROM members
      WHERE deleted_at IS NULL
      GROUP BY team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_inbound_messages AS (
      SELECT count(*) AS inbound_messages, l.team_id
      FROM conversation_messages AS cm
      INNER JOIN conversations AS c ON cm.conversation_id = c.id
      INNER JOIN locations AS l ON c.location_id = l.id
      WHERE c.original_number = cm.phone_number
      GROUP BY l.team_id
    );
    """

    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
      SELECT t.team_id, teammates, location_admins, locations, bounce_rate,
        inbound_messages, members, total_sessions,
        ROUND(inbound_messages / members) AS average_messages_per_member,
        ROUND(total_sessions / members) AS average_sessions_per_member
      FROM metrics_teammates AS t
      INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
      INNER JOIN metrics_location_admins AS la ON t.team_id = la.team_id
      INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
      INNER JOIN metrics_inbound_messages AS im ON t.team_id = im.team_id
      INNER JOIN metrics_members AS m ON t.team_id = m.team_id
      INNER JOIN metrics_sessions AS s ON t.team_id = s.team_id
    );

    """

  end

  def down do
    execute "DROP VIEW IF EXISTS metrics_teams;"
    execute """
    CREATE OR REPLACE VIEW metrics_teams AS (
      SELECT t.team_id, teammates, location_admins, locations, bounce_rate
      FROM metrics_teammates AS t
      INNER JOIN metrics_locations AS l ON t.team_id = l.team_id
      INNER JOIN metrics_location_admins AS la ON t.team_id = la.team_id
      INNER JOIN metrics_bounce_rates AS b ON t.team_id = b.team_id
    );
    """

    execute "DROP VIEW IF EXISTS metrics_sessions;"
    execute "DROP VIEW IF EXISTS metrics_members;"
    execute "DROP VIEW IF EXISTS metrics_inbound_messages;"
  end
end
